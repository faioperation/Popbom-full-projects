import z from 'zod';

export const googleOAuthSchema = z.object({
  body: z.object({
    idToken: z.string({ required_error: 'idToken is required' }),
  }),
});

export const appleOAuthSchema = z.object({
  body: z.object({
    identityToken: z.string({ required_error: 'identityToken is required' }),
    // optionally pass fullName on first sign-in
    fullName: z
      .object({
        givenName: z.string().optional(),
        familyName: z.string().optional(),
      })
      .optional(),
  }),
});