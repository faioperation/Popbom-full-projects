import { JwtPayload } from "jsonwebtoken";
import { catchAsync } from "../../app/utils/catchAsync";
import sendResponse from "../../app/utils/sendResponse";
import status from "http-status";
import AppError from "../../app/errors/AppError";
import { AiRecommendationService } from "./aiRecommendation.service";


const getFeedForUser = catchAsync(async (req, res) => {
    const user = req.user as JwtPayload;
    if (!user) {
        throw new AppError(status.UNAUTHORIZED, "User not authenticated");
    }
    const result = await AiRecommendationService.getFeedForUser(user._id);

    sendResponse(res, {
        statusCode: status.OK,
        success: true,
        message: "Feed for user retrieved successfully",
        data: result,
    });
});

const getStemFeed = catchAsync(async (req, res) => {
    const user = req.user as JwtPayload;
    if (!user) {
        throw new AppError(status.UNAUTHORIZED, "User not authenticated");
    }
    const result = await AiRecommendationService.getStemFeed(user._id);
    sendResponse(res, {
        statusCode: status.OK,
        success: true,
        message: "Stem feed retrieved successfully",
        data: result,
    });
});

export const AiRecommendationController = {
    getFeedForUser,
    getStemFeed
}