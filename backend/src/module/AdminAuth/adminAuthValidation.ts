import z from "zod";

export const AdminAuthValidations = {
    login: z.object({
        body: z.object({
            email: z.string({ required_error: 'Email is required' }).email(),
            password: z.string({ required_error: 'Password is required' }),
        })
    }),
    forgotPassword: z.object({
        body: z.object({
            email: z.string({ required_error: 'Email is required' }).email(),
        })
    }),
    verifyOTP: z.object({
        body: z.object({
            email: z.string({ required_error: 'Email is required' }).email(),
            otp: z.string({ required_error: 'OTP is required' }),
        })
    }),
    resetPassword: z.object({
        body: z.object({
            email: z.string({ required_error: 'Email is required' }).email(),
            newPassword: z.string({ required_error: 'New password is required' }).min(6),
        })
    }),
};