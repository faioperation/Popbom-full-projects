import { Request, Response } from 'express';
import { catchAsync } from '../../app/utils/catchAsync';
import sendResponse from '../../app/utils/sendResponse';
import status from 'http-status';
import { PostTagService } from './postTag.service';
import mongoose from 'mongoose';

// const attachTag = catchAsync(async (req: Request, res: Response) => {
//   const payload = { ...req.body }; // { tagId, postId }
//   const result = await PostTagService.attachTagToPost(payload);
//   sendResponse(res, {
//     statusCode: status.CREATED,
//     success: true,
//     message: 'Tag attached to post',
//     data: result,
//   });
// });

const getTagsForPost = catchAsync(async (req: Request, res: Response) => {
  const { postId } = req.params;
  // validate objectId quickly
  if (!mongoose.Types.ObjectId.isValid(postId)) {
    return sendResponse(res, {
      statusCode: status.BAD_REQUEST,
      success: false,
      message: 'Invalid postId',
      data: null,
    });
  }
  const result = await PostTagService.getTagsForPost(postId);
  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: 'Tags for post retrieved',
    data: result,
  });
});

const getPostsByTag = catchAsync(async (req: Request, res: Response) => {
  const { tagId } = req.params;
  if (!mongoose.Types.ObjectId.isValid(tagId)) {
    return sendResponse(res, {
      statusCode: status.BAD_REQUEST,
      success: false,
      message: 'Invalid tagId',
      data: null,
    });
  }
  const result = await PostTagService.getPostsByTag(tagId);
  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: 'Posts for tag retrieved',
    data: result,
  });
});

const removePostTagById = catchAsync(async (req: Request, res: Response) => {
  const { id } = req.params;
  await PostTagService.removePostTagById(id);
  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: 'PostTag removed',
    data: null,
  });
});

const removePostTag = catchAsync(async (req: Request, res: Response) => {
  const { postId, tagId } = req.body;
  await PostTagService.removePostTag(postId, tagId);
  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: 'PostTag removed',
    data: null,
  });
});

export const PostTagController = {
  // attachTag,
  getTagsForPost,
  getPostsByTag,
  removePostTagById,
  removePostTag,
};
