import { z } from "zod";

const createTagSchema = z.object({
  body: z.object({
    tagName: z.string({ required_error: 'Tag name is required' }),
  }),
});

export const TagValidation = {
  createTagSchema
};