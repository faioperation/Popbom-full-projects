import { Request, Response } from "express";
import { catchAsync } from "../../app/utils/catchAsync";
import sendResponse from "../../app/utils/sendResponse";
import status from "http-status";
import { GiftService } from "./gift.service";

const sendGift = catchAsync(async (req: Request, res: Response) => {
  const payload = { ...req.body, authorId: req.user?.id };
  const result = await GiftService.sendGift(payload);

  sendResponse(res, {
    statusCode: status.CREATED,
    success: true,
    message: 'Gift sent successfully',
    data: result,
  });
});


export const GiftController = {
  sendGift,
};
