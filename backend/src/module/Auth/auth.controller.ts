import status from "http-status";
import config from "../../app/config";
import { catchAsync } from "../../app/utils/catchAsync";
import sendResponse from "../../app/utils/sendResponse";
import { AuthService } from "./auth.service";

// VERIFY OTP
const verifyOTP = catchAsync(async (req, res) => {
  const { email, otp } = req.body;

  await AuthService.verifyOTP({ email, otp });

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: 'OTP verified successfully. You can now reset your password.',
    data: null,
  });
});


// FORGOT PASSWORD
const forgotPassword = catchAsync(async (req, res) => {
  const { email } = req.body;

  await AuthService.forgotPassword(email);

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: 'OTP has been sent to your email',
    data: null,
  });
});

// RESET PASSWORD
const resetPassword = catchAsync(async (req, res) => {
  const { email, newPassword } = req.body;

  await AuthService.resetPassword({ email, newPassword });

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: 'Password has been reset successfully',
    data: null,
  });
});


// login user
const loginUser = catchAsync(async (req, res) => {
  const result = await AuthService.loginUser(req.body);

  const { accessToken, refreshToken } = result;

  res.cookie('refreshToken', refreshToken, {
    secure: config.NODE_ENV === 'production',
    httpOnly: true,
    sameSite: config.NODE_ENV === 'production' ? 'none' : 'lax',
    maxAge: 1000 * 60 * 60 * 24 * 7,
  });

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: 'User is logged in successfully!',
    data: { accessToken, refreshToken },
  });
});

const registerUser = catchAsync(async (req, res) => {
  const result = await AuthService.registerUser(req.body);

  sendResponse(res, {
    statusCode: status.CREATED,
    success: true,
    message: 'User is registered successfully!',
    data: result
  });
});

const refreshToken = catchAsync(async (req, res) => {
  const { refreshToken } = req.cookies;
  if (!refreshToken) {
    return sendResponse(res, {
      statusCode: status.BAD_REQUEST,
      success: false,
      message: 'Refresh token not found',
      data: null
    });
  }
  const result = await AuthService.refreshToken(refreshToken);

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: 'Access token is retrieved successfully!',
    data: result,
  });
});

const logoutUser = catchAsync(async (req, res) => {
  const { refreshToken } = req.cookies;

  if (!refreshToken) {
    return sendResponse(res, {
      statusCode: status.BAD_REQUEST,
      success: false,
      message: 'Refresh token not found',
      data: null
    });
  }
  await AuthService.logoutUser(refreshToken);

  res.clearCookie('refreshToken', {
    secure: config.NODE_ENV === 'production',
    httpOnly: true,
    sameSite: config.NODE_ENV === 'production' ? 'none' : 'lax',
  });

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: 'User is logged out successfully!',
    data: null,
  });
});

const changePassword = catchAsync(async (req, res) => {
  const user = req.user;
  const { currentPassword, newPassword } = req.body;

  await AuthService.changePassword(user, { currentPassword, newPassword });

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: "Password changed successfully",
    data: null,
  });
});

export const AuthController = {
  loginUser,
  registerUser,
  refreshToken,
  logoutUser,
  forgotPassword,
  resetPassword,
  verifyOTP,
  changePassword
};