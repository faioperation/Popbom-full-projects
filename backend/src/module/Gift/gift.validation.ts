import { z } from "zod";

const sendGiftSchema = z.object({
  body: z.object({
    userId: z.string({ required_error: 'Recipient userId is required' }),
    giftType: z.enum(['coin','heart','rose','star','fire'], { required_error: 'Gift type is required' }),
  }),
});

export const GiftValidation = {
  sendGiftSchema
};
