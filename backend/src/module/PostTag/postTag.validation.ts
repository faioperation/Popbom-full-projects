import { z } from 'zod';

const attachSchema = z.object({
  body: z.object({
    tagId: z.string({ required_error: 'tagId is required' }),
    postId: z.string({ required_error: 'postId is required' }),
  }),
});

const removeByPostTagSchema = z.object({
  body: z.object({
    tagId: z.string({ required_error: 'tagId is required' }),
    postId: z.string({ required_error: 'postId is required' }),
  }),
});

export const PostTagValidation = {
  attachSchema,
  removeByPostTagSchema,
};
