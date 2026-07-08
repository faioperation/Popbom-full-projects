import { catchAsync } from '../../app/utils/catchAsync';
import sendResponse from '../../app/utils/sendResponse';
import status from 'http-status';
import { AdminAuthService } from './adminAuth.service';
import config from '../../app/config';

const loginAdmin = catchAsync(async (req, res) => {
  const result = await AdminAuthService.login(req.body);

  const { accessToken, refreshToken, user } = result;

  res.cookie('accessToken', accessToken, {
    secure: config.NODE_ENV === 'production',
    httpOnly: true,
    sameSite: config.NODE_ENV === 'production' ? 'none' : 'lax',
    maxAge: 1000 * 60 * 60 * 24 * 7,
  });
  res.cookie('refreshToken', refreshToken, {
    secure: config.NODE_ENV === 'production',
    httpOnly: true,
    sameSite: config.NODE_ENV === 'production' ? 'none' : 'lax',
    maxAge: 1000 * 60 * 60 * 24 * 7,
  });

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: 'Admin logged in successfully',
    data: { accessToken, refreshToken, user },
  });
});

const forgotPassword = catchAsync(async (req, res) => {
  const { email } = req.body;

  await AdminAuthService.forgotPassword(email);
  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: 'Password reset OTP sent to email',
    data: null,
  });
});

const verifyOTP = catchAsync(async (req, res) => {
  const { email, otp } = req.body;
  const result = await AdminAuthService.verifyOTP(email, otp);
  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: 'OTP verified successfully',
  });
});

const resetPassword = catchAsync(async (req, res) => {
  const { email, newPassword } = req.body;
  const result = await AdminAuthService.resetPassword(email, newPassword);
  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: 'Password reset successfully',
  });
});
export const AdminAuthController = {
  loginAdmin,
  forgotPassword,
  verifyOTP,
  resetPassword,
};
