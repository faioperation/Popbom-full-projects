import { z } from "zod";

const createNotificationSchema = z.object({
  body: z.object({
    userId: z.string({ required_error: 'User ID (recipient) is required' }),
    senderId: z.string({ required_error: 'Sender ID is required' }),
    type: z.string({ required_error: 'Type is required' }),
    message: z.string({ required_error: 'Message is required' }),
    linkType: z.enum(['chat', 'post', 'comment', 'profile', 'challenge', 'gift', 'follow']).optional(),
    linkId: z.string().optional(),
  }),
});

export const NotificationValidation = {
  createNotificationSchema
};
