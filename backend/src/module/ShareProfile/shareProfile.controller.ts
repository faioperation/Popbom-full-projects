import { Request, Response } from "express";
import { catchAsync } from "../../app/utils/catchAsync";
import { ShareProfileServices } from "./shareProfile.service";
import sendResponse from "../../app/utils/sendResponse";
import status from "http-status";
import { JwtPayload } from "jsonwebtoken";

const getShareProfileData = catchAsync(async (req: Request, res: Response) => {
    const user = req.user as JwtPayload;
    const result = await ShareProfileServices.getShareProfileDataFromDB(user.id);

    sendResponse(res, {
        statusCode: status.OK,
        success: true,
        message: "Share profile data retrieved successfully",
        data: result,
    });
});

const getShareProfileDataByUsername = catchAsync(async (req: Request, res: Response) => {
    const { username } = req.params;
    console.log(username);
    const result = await ShareProfileServices.getShareProfileDataByUsername(username);
    sendResponse(res, {
        statusCode: status.OK,
        success: true,
        message: "Share profile data retrieved successfully",
        data: result,
    });
});

export const ShareProfileControllers = {
    getShareProfileData,
    getShareProfileDataByUsername,
};
