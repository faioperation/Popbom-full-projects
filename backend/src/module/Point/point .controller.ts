import { Request, Response } from 'express';
import { catchAsync } from '../../app/utils/catchAsync';
import sendResponse from '../../app/utils/sendResponse';
import status from 'http-status';
import { User } from '../User/user.modal';
import { PointHistory } from './point.model';

const getUserPoints = catchAsync(async (req: Request, res: Response) => {
  const { userId } = req.params;
  const user = await User.findById(userId).select('points').lean();
  const points = user?.points ?? 0;
  sendResponse(res, { statusCode: status.OK, success: true, message: 'User points', data: { points }});
});

const getPointHistory = catchAsync(async (req: Request, res: Response) => {
  const { userId } = req.params;
  const history = await PointHistory.find({ userId }).sort({ createdAt: -1 }).limit(100).lean();
  sendResponse(res, { statusCode: status.OK, success: true, message: 'Point history', data: history});
});

export const PointController = { getUserPoints, getPointHistory };
