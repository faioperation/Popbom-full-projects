import httpStatus from 'http-status';
import { Admin } from './adminAuth.modal';
import { TLoginAdmin } from './adminAuth.interface';
import AppError from '../../app/errors/AppError';
import { createToken } from './adminAuth.utils';
import config from '../../app/config';
import jwt, { JwtPayload } from 'jsonwebtoken';
import { generateOTP } from '../../app/utils/generateOtp';
import { sendEmail } from '../../app/utils/email';
import status from 'http-status';
import bcrypt from 'bcrypt';

/* 🔹 Login Admin */
const login = async (payload: TLoginAdmin) => {
  const admin = await Admin.isAdminExistByEmail(payload.email);
  if (!admin) {
    throw new AppError(httpStatus.NOT_FOUND, 'Admin not found');
  }

  const isPasswordMatched = await Admin.isPasswordMatched(
    payload.password,
    admin.password,
  );

  if (!isPasswordMatched) {
    throw new AppError(httpStatus.UNAUTHORIZED, 'Password is incorrect');
  }
  const jwtPayload = {
    adminId: admin._id!.toString(),
    email: admin.email,
    role: admin.role || 'admin',
  };

  const accessToken = createToken(
    jwtPayload,
    config.jwt_access_secret as string,
  );
  const refreshToken = createToken(
    jwtPayload,
    config.jwt_refresh_secret as string,
  );

  return {
    accessToken,
    refreshToken,
    user: {
      adminId: admin._id!.toString(),
      email: admin.email,
      name: admin.name,
    },
  };
};

const forgotPassword = async (email: string) => {
  const admin = await Admin.isAdminExistByEmail(email);
  if (!admin) {
    throw new AppError(httpStatus.NOT_FOUND, 'Admin not found');
  }
  const otp = generateOTP();
  const otpExpiry = new Date(Date.now() + 15 * 60 * 1000); // 15 minutes

  admin.passwordResetOTP = otp;
  admin.passwordResetExpires = otpExpiry;
  admin.isOTPVerified = false;

  await admin.save();

  await sendEmail({
    to: admin.email,
    subject: 'Your Password Reset OTP',
    text: `Your OTP for resetting password is: ${otp}. It expires in 15 minutes.`,
  });

  return true;
};

const verifyOTP = async (email: string, otp: string) => {
  const admin = await Admin.findOne({ email }).select('+passwordResetOTP +passwordResetExpires');

  if (!admin || !admin.passwordResetOTP || !admin.passwordResetExpires) {
    throw new AppError(status.BAD_REQUEST, 'Invalid password reset request');
  }

  if (admin.passwordResetOTP !== otp) {
    throw new AppError(status.UNAUTHORIZED, 'Invalid OTP');
  }

  if (admin.passwordResetExpires! < new Date()) {
    throw new AppError(status.UNAUTHORIZED, 'OTP has expired');
  }
  admin.isOTPVerified = true;
  await admin.save();

  return true;
};

const resetPassword = async (email: string, newPassword: string) => {
  const admin = await Admin.isAdminExistByEmail(email);
  if (!admin) {
    throw new AppError(httpStatus.NOT_FOUND, 'Admin not found');
  }
  admin.password = newPassword;
  admin.passwordResetOTP = null;
  admin.passwordResetExpires = null;
  admin.isOTPVerified = false;
  await admin.save();
  return true;
};

export const AdminAuthService = {
  login,
  forgotPassword,
  verifyOTP,
  resetPassword,
};
