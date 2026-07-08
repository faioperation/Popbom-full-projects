import { Request, Response } from "express";
import { catchAsync } from "../../app/utils/catchAsync";
import sendResponse from "../../app/utils/sendResponse";
import status from "http-status";
import AppError from "../../app/errors/AppError";
import { JwtPayload } from "jsonwebtoken";
import { PostWatchCountServices } from "./watchCount.service";

/**
 * POST /api/post-watch-count/increment
 * body: { postId, amount? }
 * protected (user)
 */
const incrementWatch = catchAsync(async (req: Request, res: Response) => {
  if (!req.body.postId) throw new AppError(status.BAD_REQUEST, "postId is required");
  const amount = Number(req.body.amount) || 1;

  const postId = req.body.postId;
  const updated = await PostWatchCountServices.incrementWatchCount(postId, amount);

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: "Watch count incremented",
    data: updated,
  });
});

/**
 * GET /api/post-watch-count/:postId
 * public
 */
const getWatchCount = catchAsync(async (req: Request, res: Response) => {
  const { postId } = req.params;
  const rec = await PostWatchCountServices.getWatchCountByPost(postId);

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    data: rec,
  });
});

/**
 * PATCH /api/post-watch-count/set
 * body: { postId, count }
 * protected (admin recommended)
 */
const setWatchCount = catchAsync(async (req: Request, res: Response) => {
  const { postId, count } = req.body;
  if (!postId) throw new AppError(status.BAD_REQUEST, "postId is required");
  if (count === undefined) throw new AppError(status.BAD_REQUEST, "count is required");

  const rec = await PostWatchCountServices.setWatchCount(postId, Number(count));

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: "Watch count set",
    data: rec,
  });
});

/**
 * DELETE /api/post-watch-count/:postId
 * reset to zero (admin)
 */
const resetWatchCount = catchAsync(async (req: Request, res: Response) => {
  const { postId } = req.params;
  if (!postId) throw new AppError(status.BAD_REQUEST, "postId is required");

  const rec = await PostWatchCountServices.resetWatchCount(postId);

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: "Watch count reset",
    data: rec,
  });
});

export const PostWatchCountController = {
  incrementWatch,
  getWatchCount,
  setWatchCount,
  resetWatchCount,
};
