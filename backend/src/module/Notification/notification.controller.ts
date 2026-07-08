import { Request, Response } from "express";
import { catchAsync } from "../../app/utils/catchAsync";
import sendResponse from "../../app/utils/sendResponse";
import status from "http-status";
import { NotificationService } from "./notification.service";

const createNotification = catchAsync(async (req: Request, res: Response) => {
  const result = await NotificationService.sendNotification(req.body);

  sendResponse(res, {
    statusCode: status.CREATED,
    success: true,
    message: 'Notification created successfully',
    data: result,
  });
});

const getUserNotifications = catchAsync(async (req: Request, res: Response) => {
  const { userId } = req.params;
  const result = await NotificationService.getNotificationsForUser(userId);

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: 'Notifications retrieved successfully',
    data: result,
  });
});

const markAsRead = catchAsync(async (req: Request, res: Response) => {
  const { id } = req.params;
  const result = await NotificationService.markAsRead(id);

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: 'Notification marked as read',
    data: result,
  });
});

export const NotificationController = {
  createNotification,
  getUserNotifications,
  markAsRead
};
