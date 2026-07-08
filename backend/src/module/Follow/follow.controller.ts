import { Request, Response } from 'express';
import { catchAsync } from '../../app/utils/catchAsync';
import sendResponse from '../../app/utils/sendResponse';
import status from 'http-status';
import { FollowServices } from './follow.service';
import AppError from '../../app/errors/AppError';
import { JwtPayload } from 'jsonwebtoken';

const toggleFollow = catchAsync(async (req: Request, res: Response) => {
  if (!req.user) throw new AppError(status.UNAUTHORIZED, 'User not authenticated');

  const followerId = (req.user as JwtPayload).id as string;
  const { followedUserId } = req.body;
  if (!followedUserId) throw new AppError(status.BAD_REQUEST, 'followedUserId is required');

  const result = await FollowServices.toggleFollow(followerId, followedUserId);

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: result.followed ? 'User followed' : 'User unfollowed',
    data: result.record || null,
  });
});

const getFollowers = catchAsync(async (req: Request, res: Response) => {
  const userId = req.params.userId;

  const data = await FollowServices.getFollowers(userId);

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: 'Followers retrieved',
    data,
  });
});

const getFollowing = catchAsync(async (req: Request, res: Response) => {

  const userId = req.params.userId;

  const data = await FollowServices.getFollowing(userId);

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: 'Following retrieved',
    data,
  });
});

const unfollow = catchAsync(async (req: Request, res: Response) => {
  if (!req.user) throw new AppError(status.UNAUTHORIZED, 'User not authenticated');
  const user = req.user as JwtPayload;

  await FollowServices.unfollowById(req.params.id, user);

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: 'Follow removed',
    data: null,
  });
});

// Optional quick check: GET /is-following?targetId=...
const isFollowing = catchAsync(async (req: Request, res: Response) => {
  if (!req.user) throw new AppError(status.UNAUTHORIZED, 'User not authenticated');
  const followerId = (req.user as JwtPayload).id as string;
  const targetId = String(req.query.targetId || '');

  if (!targetId) throw new AppError(status.BAD_REQUEST, 'targetId is required');

  const result = await FollowServices.isFollowing(followerId, targetId);

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: result ? 'Following' : 'Not following',
    data: { isFollowing: result },
  });
});

export const FollowController = {
  toggleFollow,
  getFollowers,
  getFollowing,
  unfollow,
  isFollowing,
};
