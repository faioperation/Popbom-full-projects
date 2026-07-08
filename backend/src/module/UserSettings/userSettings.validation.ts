import { z } from "zod";

const createOrUpdateSchema = z.object({
  body: z.object({
    themePreference: z.enum(['light', 'dark']).optional(),
    notificationEnabled: z.boolean().optional(),
  }),
});

export const UserSettingsValidation = {
  createOrUpdateSchema,
};