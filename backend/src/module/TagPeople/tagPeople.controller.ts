import { Request, Response } from 'express';
import { catchAsync } from '../../app/utils/catchAsync';
import sendResponse from '../../app/utils/sendResponse';
import status from 'http-status';
import { TagPeopleService } from './tagPeople.service';

const tagUser = catchAsync(async (req: Request, res: Response) => {
  const payload = { ...req.body }; // { postId, userId }
  const result = await TagPeopleService.tagPerson(payload);
  sendResponse(res, {
    statusCode: status.CREATED,
    success: true,
    message: 'User tagged successfully',
    data: result,
  });
});

const getTaggedUsers = catchAsync(async (req: Request, res: Response) => {
  const { postId } = req.params;
  const result = await TagPeopleService.getTaggedUsersByPost(postId);
  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: 'Tagged users retrieved successfully',
    data: result,
  });
});

const getTaggedPosts = catchAsync(async (req: Request, res: Response) => {
  const { userId } = req.params;
  const result = await TagPeopleService.getTaggedPostsByUser(userId);
  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: 'Tagged posts retrieved successfully',
    data: result,
  });
});

const removeTag = catchAsync(async (req: Request, res: Response) => {
  const { id } = req.params; // tag document id
  await TagPeopleService.removeTagById(id);
  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: 'Tag removed successfully',
    data: null,
  });
});

// optional delete by post & user (use query or route if you prefer)
const removeTagByPostUser = catchAsync(async (req: Request, res: Response) => {
  const { postId, userId } = req.body;
  await TagPeopleService.removeTagByPostAndUser(postId, userId);
  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: 'Tag removed successfully',
    data: null,
  });
});

export const TagPeopleController = {
  tagUser,
  getTaggedUsers,
  getTaggedPosts,
  removeTag,
  removeTagByPostUser,
};
