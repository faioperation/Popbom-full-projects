import z from "zod";

const updateProfileValidationSchema = z.object({
  body: z.object({
    name: z.string({ required_error: 'Name is required' }).optional()
  }),
});

const updatePhotoValidationSchema = z.object({
  body: z.object({
    photo: z.string({ required_error: 'Photo is required' }).optional(),
  }),
});

const updateProfileAndPasswordSchema = z.object({
  body: z.object({
    username: z.string().optional(),
    name: z.string().optional(),
    email: z.string().optional(),
    mobile:z.string().optional(),
    currentPassword: z.string().optional(),
    newPassword: z.string().optional(),
  }).refine((data) => {
    if (data.currentPassword) {
      return !!data.newPassword;
    }
    return true;
  }, {
    message: "newPassword is required when currentPassword is provided",
    path: ["newPassword"],
  }),
});

export const UserValidation = {
  updateProfileValidationSchema,
  updatePhotoValidationSchema,
  updateProfileAndPasswordSchema
};
