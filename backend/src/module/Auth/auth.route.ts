import { Router } from "express";
import auth from "../../app/middleware/auth";
import { USER_ROLE } from "../User/user.constant";
import { AuthController } from "./auth.controller";
import validateRequest from "../../app/middleware/validateRequest";
import { AuthValidations } from "./authValidation";
import { AuthOAuthController } from "./auth.oauth.controller";
import { appleOAuthSchema, googleOAuthSchema } from "./auth.oauth.validation";

const router = Router();

router.post(
    '/logout',
    auth(USER_ROLE.admin, USER_ROLE.user),
    AuthController.logoutUser
);

router.post(
    '/register',
    validateRequest(AuthValidations.registerUserValidationSchema),
    AuthController.registerUser
);

router.post(
    '/login',
    validateRequest(AuthValidations.loginValidationSchema),
    AuthController.loginUser,
);

router.post(
    '/refresh-token',
    AuthController.refreshToken,
)

router.post(
  '/forgot-password',
  validateRequest(AuthValidations.forgotPasswordSchema),
  AuthController.forgotPassword
);

router.post(
  '/verify-otp',
  validateRequest(AuthValidations.verifyOTPSchema),
  AuthController.verifyOTP
);

router.post(
  '/reset-password',
  validateRequest(AuthValidations.resetPasswordSchema),
  AuthController.resetPassword
);

router.post(
  "/change-password",
  auth(USER_ROLE.user, USER_ROLE.admin),
  validateRequest(AuthValidations.changePasswordSchema),
  AuthController.changePassword
);

router.post(
  "/google",
  validateRequest(googleOAuthSchema),
  AuthOAuthController.googleAuth
);

router.post(
  "/apple",
  validateRequest(appleOAuthSchema),
  AuthOAuthController.appleAuth
);


export const AuthRoutes = router;