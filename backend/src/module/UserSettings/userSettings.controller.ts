import { Request, Response } from "express";
import { catchAsync } from "../../app/utils/catchAsync";
import sendResponse from "../../app/utils/sendResponse";
import status from "http-status";
import { UserSettingsService } from "./userSettings.service";

const createOrUpdate = catchAsync(async (req: Request, res: Response) => {
  const userId = req.params.userId;
  const payload = req.body;

  const result = await UserSettingsService.createOrUpdateSettings(userId, payload);

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: 'User settings saved successfully',
    data: result,
  });
});

const getSettings = catchAsync(async (req: Request, res: Response) => {
  const userId = req.params.userId;

  const result = await UserSettingsService.getSettingsByUserId(userId);

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: 'User settings retrieved successfully',
    data: result,
  });
});

export const UserSettingsController = {
  createOrUpdate,
  getSettings,
};
