import { Request, Response } from 'express';
import { catchAsync } from '../../app/utils/catchAsync';
import sendResponse from '../../app/utils/sendResponse';
import status from 'http-status';
import { oauthLogin } from './auth.oauth.service';
import config from '../../app/config';

// google auth 
const googleAuth = catchAsync(async (req: Request, res: Response) => {
  const { idToken } = req.body;
  const result = await oauthLogin('google', idToken);
  res.cookie('refreshToken', result.refreshToken, {
    secure: config.NODE_ENV === 'production',
    httpOnly: true,
    sameSite: config.NODE_ENV === 'production' ? 'none' : 'lax',
    maxAge: 7 * 24 * 60 * 60 * 1000,
  });
  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: 'Google login successful',
    data: { accessToken: result.accessToken },
  });
});

// apple auth 
const appleAuth = catchAsync(async (req: Request, res: Response) => {
  const { identityToken, fullName } = req.body;
  const result = await oauthLogin('apple', identityToken, { fullName });
  res.cookie('refreshToken', result.refreshToken, {
    secure: config.NODE_ENV === 'production',
    httpOnly: true,
    sameSite: config.NODE_ENV === 'production' ? 'none' : 'lax',
    maxAge: 7 * 24 * 60 * 60 * 1000,
  });
  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: 'Apple login successful',
    data: { accessToken: result.accessToken },
  });
});

export const AuthOAuthController = {
  googleAuth,
  appleAuth,
};
