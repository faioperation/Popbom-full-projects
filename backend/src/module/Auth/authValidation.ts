import { z } from 'zod';

const phoneRegex = /^\+?[0-9]{7,15}$/;

const registerUserValidationSchema = z.object({
  body: z.object({
    name: z.string({
      required_error: 'Name is required',
    }),
    email: z
      .string({
        required_error: 'Email is required',
      })
      .email(),
    mobile: z
      .string()
      .optional()
      .refine((val) => (val === undefined ? true : phoneRegex.test(val)), {
        message: "Mobile must be a valid phone number (digits, optional leading +).",
      }),
    password: z.string({
      required_error: 'Password is required',
    }),
  }),
});

const loginValidationSchema = z.object({
  body: z.object({
    email: z.string({ required_error: 'Email is required' }).email(),
    password: z.string({ required_error: 'Password is required' }),
  }),
});

const refreshTokenValidationSchema = z.object({
  cookies: z.object({
    refreshToken: z.string({ required_error: 'Refresh token is required' }),
  }),
});

const forgotPasswordSchema = z.object({
  body: z.object({
    email: z.string({ required_error: 'Email is required' }).email(),
  }),
});

const verifyOTPSchema = z.object({
  body: z.object({
    email: z.string({ required_error: 'Email is required' }).email(),
    otp: z.string({ required_error: 'OTP is required' })
  }),
});
const resetPasswordSchema = z.object({
  body: z.object({
    email: z.string({ required_error: 'Email is required' }).email(),
    newPassword: z.string({ required_error: 'New password is required' }).min(6),
  }),
});

const changePasswordSchema = z.object({
  body: z.object({
    currentPassword: z.string({ required_error: "Current password is required" }).min(6),
    newPassword: z.string({ required_error: "New password is required" }).min(6),
  }),
});


export const AuthValidations = {
  registerUserValidationSchema,
  loginValidationSchema,
  refreshTokenValidationSchema,
  forgotPasswordSchema,
  verifyOTPSchema,
  resetPasswordSchema,
  changePasswordSchema
};