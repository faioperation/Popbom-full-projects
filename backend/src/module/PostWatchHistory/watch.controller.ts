import { Request, Response } from "express";
import { catchAsync } from "../../app/utils/catchAsync";
import sendResponse from "../../app/utils/sendResponse";
import status from "http-status";
import AppError from "../../app/errors/AppError";
import { JwtPayload } from "jsonwebtoken";
import { PostWatchServices } from "./watch.service";


const recordWatch = catchAsync(async (req: Request, res: Response) => {
  if (!req.user) throw new AppError(status.UNAUTHORIZED, "User not authenticated");

  const userId = (req.user as JwtPayload).id as string;
  const { postId } = req.body;
  if (!postId) throw new AppError(status.BAD_REQUEST, "postId is required");

  const rec = await PostWatchServices.recordWatch(userId, postId);

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: "Watch recorded",
    data: rec,
  });
});

/**
 * GET /api/post-watch/user/:userId?page=&limit=
 * Get paginated watch history for a user
 */
const getWatchesByUser = catchAsync(async (req: Request, res: Response) => {
  const userId = req.params.userId;

  const data = await PostWatchServices.getWatchesByUser(userId);

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: "User watch history retrieved",
    data,
  });
});

/**
 * GET /api/post-watch/post/:postId?page=&limit=
 * Get paginated watch records for a post
 */
const getWatchesByPost = catchAsync(async (req: Request, res: Response) => {
  const postId = req.params.postId;

  const data = await PostWatchServices.getWatchesByPost(postId);

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: "Post watch records retrieved",
    data,
  });
});

const getWatchById = catchAsync(async (req: Request, res: Response) => {
  const rec = await PostWatchServices.getWatchById(req.params.id);

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    data: rec,
  });
});

const deleteWatch = catchAsync(async (req: Request, res: Response) => {
  if (!req.user) throw new AppError(status.UNAUTHORIZED, "User not authenticated");

  const user = req.user as JwtPayload;
  await PostWatchServices.deleteWatch(req.params.id, user);

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: "Watch record deleted",
    data: null,
  });
});

export const PostWatchController = {
  recordWatch,
  getWatchesByUser,
  getWatchesByPost,
  getWatchById,
  deleteWatch,
};
