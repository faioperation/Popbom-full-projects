import { PostTag } from './postTag.model';
import { IPostTag } from './postTag.interface';
import AppError from '../../app/errors/AppError';
import status from 'http-status';

// const attachTagToPost = async (payload: Partial<IPostTag>) => {
//   // unique index prevents duplicates; handle duplicate key error at controller level if needed
//   const tag = await PostTag.create(payload);
//   return tag;
// };

const getTagsForPost = async (postId: string) => {
  return await PostTag.find({ postId })
    .populate('tagId', 'tagName')
    .sort({ createdAt: -1 });
};

const getPostsByTag = async (tagId: string) => {
  return await PostTag.find({ tagId })
    .populate('postId', 'title body authorId createdAt')
    .sort({ createdAt: -1 });
};

const removePostTagById = async (id: string) => {
  const tag = await PostTag.findByIdAndDelete(id);
  if (!tag) throw new AppError(status.NOT_FOUND, 'PostTag not found');
  return true;
};

const removePostTag = async (postId: string, tagId: string) => {
  const tag = await PostTag.findOneAndDelete({ postId, tagId });
  if (!tag) throw new AppError(status.NOT_FOUND, 'PostTag not found');
  return true;
};

export const PostTagService = {
  // attachTagToPost,
  getTagsForPost,
  getPostsByTag,
  removePostTagById,
  removePostTag,
};
