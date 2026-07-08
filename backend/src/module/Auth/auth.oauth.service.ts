import { OAuth2Client } from 'google-auth-library';
import AppleAuth from 'apple-signin-auth';
import config from '../../app/config';
import { User } from '../User/user.modal';
import { createToken } from './auth.utils';
import { JwtPayload } from 'jsonwebtoken';
import { AuthService } from './auth.service';
import AppError from '../../app/errors/AppError';
import status from 'http-status';
import crypto from 'crypto';

const googleClient = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

export const verifyGoogleIdToken = async (idToken: string) => {
  try {
    const ticket = await googleClient.verifyIdToken({
      idToken,
      audience: process.env.GOOGLE_CLIENT_ID,
    });
    const payload = ticket.getPayload();
    if (!payload) {
      throw new AppError(status.UNAUTHORIZED, 'Invalid Google token');
    }
    return payload as any;
  } catch (error) {
    throw new AppError(status.UNAUTHORIZED, 'Failed to verify Google token');
  }
};

export const verifyAppleIdentityToken = async (identityToken: string) => {
  try {
    const payload = await AppleAuth.verifyIdToken(identityToken, {
      audience: process.env.APPLE_CLIENT_ID,
      ignoreExpiration: false,
    });
    return payload as any;
  } catch (error) {
    throw new AppError(status.UNAUTHORIZED, 'Failed to verify Apple token');
  }
};

const findOrCreateUserFromProvider = async ({
  provider,
  providerId,
  email,
  name,
}: {
  provider: 'google' | 'apple';
  providerId: string;
  email?: string;
  name?: string;
}) => {

  const providerField = provider === 'google' ? { googleId: providerId } : { appleId: providerId };
  let user = await User.findOne(providerField);

  if (!user && email) {
    user = await User.findOne({ email });
    if (user) {
      if (provider === 'google') user.googleId = providerId;
      else user.appleId = providerId;
      user.provider = provider;
      await user.save();
    }
  }

  if (!user) {
    // Email is required for creating a new user
    // Note: Apple should provide email on first sign-in, but may not on subsequent logins
    // In that case, we should have found the user by appleId above
    if (!email) {
      throw new AppError(
        status.BAD_REQUEST,
        'Email is required for account creation. Please ensure your OAuth provider returns an email address.'
      );
    }

    // create new user
    const usernameBase = (name || email || 'user').split('@')[0];
    const username = await AuthService.generateUniqueUsername(usernameBase);

    // Generate a random password for OAuth users (they won't use it)
    const randomPassword = crypto.randomBytes(32).toString('hex');

    user = await User.create({
      username,
      email,
      password: randomPassword, // OAuth users don't use password, but schema requires it
      provider,
      googleId: provider === 'google' ? providerId : undefined,
      appleId: provider === 'apple' ? providerId : undefined,
    });
  }

  return user;
};

export const oauthLogin = async (provider: 'google' | 'apple', token: string, extras: any = {}) => {
  if (provider === 'google') {
    const payload = await verifyGoogleIdToken(token);
    const { sub: googleId, email, email_verified, name, picture } = payload;

    if (!email_verified) {
      throw new AppError(status.UNAUTHORIZED, 'Google email is not verified');
    }

    if (!email) {
      throw new AppError(status.BAD_REQUEST, 'Email is required from Google');
    }

    const user = await findOrCreateUserFromProvider({
      provider: 'google',
      providerId: googleId,
      email,
      name: name || undefined,
    });

    const jwtPayload = { userId: user._id!.toString(), email: user.email, role: user.role } as JwtPayload;
    const accessToken = createToken(jwtPayload as any, config.jwt_access_secret as string);
    const refreshToken = createToken(jwtPayload as any, config.jwt_refresh_secret as string);

    return { user, accessToken, refreshToken };
  } else {
    const payload = await verifyAppleIdentityToken(token);
    const { sub: appleId, email } = payload;

    // Extract name from extras if provided (Apple sends fullName only on first sign-in)
    let name = '';
    if (extras?.fullName) {
      const { givenName, familyName } = extras.fullName;
      name = [givenName, familyName].filter(Boolean).join(' ').trim();
    }

    const user = await findOrCreateUserFromProvider({
      provider: 'apple',
      providerId: appleId,
      email: email || undefined,
      name: name || undefined,
    });

    const jwtPayload = { userId: user._id!.toString(), email: user.email, role: user.role } as JwtPayload;
    const accessToken = createToken(jwtPayload as any, config.jwt_access_secret as string);
    const refreshToken = createToken(jwtPayload as any, config.jwt_refresh_secret as string);

    return { user, accessToken, refreshToken };
  }
};
