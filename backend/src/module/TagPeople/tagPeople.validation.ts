import { z } from 'zod';

const tagSchema = z.object({
  body: z.object({
    postId: z.string({ required_error: 'postId is required' }),
    userId: z.string({ required_error: 'userId is required' }),
  }),
});

const removeByPostUserSchema = z.object({
  body: z.object({
    postId: z.string({ required_error: 'postId is required' }),
    userId: z.string({ required_error: 'userId is required' }),
  }),
});

export const TagPeopleValidation = {
  tagSchema,
  removeByPostUserSchema,
};