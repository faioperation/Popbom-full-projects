import { TagPerson } from './tagPeople.model';
import { ITagPerson } from './tagPeople.interface';
import AppError from '../../app/errors/AppError';
import status from 'http-status';
import { NotificationService } from '../Notification/notification.service';
import { Post } from '../Post/post.model';

const tagPerson = async (payload: Partial<ITagPerson>) => {
  // create, unique index will prevent duplicates
  const tag = await TagPerson.create(payload);

  if (tag) {
    const post = await Post.findById(tag.postId);
    await NotificationService.sendNotification({
      userId: tag.userId as any,
      senderId: post?.authorId as any, // The person who tagged them (usually the post author)
      type: 'tag',
      message: 'tagged you in a post',
      linkType: 'post',
      linkId: tag.postId as any,
    });
  }

  return tag;
};

const getTaggedUsersByPost = async (postId: string) => {
  return await TagPerson.find({ postId })
    .populate('userId', 'name photo email')
    .sort({ createdAt: -1 });
};

const getTaggedPostsByUser = async (userId: string) => {
  return await TagPerson.find({ userId })
    .populate('postId', 'title body authorId createdAt')
    .sort({ createdAt: -1 });
};

const removeTagById = async (id: string) => {
  const tag = await TagPerson.findByIdAndDelete(id);
  if (!tag) throw new AppError(status.NOT_FOUND, 'Tag not found');
  return true;
};

// optional: remove tag by postId + userId
const removeTagByPostAndUser = async (postId: string, userId: string) => {
  const tag = await TagPerson.findOneAndDelete({ postId, userId });
  if (!tag) throw new AppError(status.NOT_FOUND, 'Tag not found');
  return true;
};

export const TagPeopleService = {
  tagPerson,
  getTaggedUsersByPost,
  getTaggedPostsByUser,
  removeTagById,
  removeTagByPostAndUser,
};
