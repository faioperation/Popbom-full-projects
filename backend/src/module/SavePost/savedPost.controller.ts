import { Request, Response } from "express";
import { catchAsync } from "../../app/utils/catchAsync";
import sendResponse from "../../app/utils/sendResponse";
import status from "http-status";
import { JwtPayload } from "jsonwebtoken";
import AppError from "../../app/errors/AppError";
import { SavedPostServices } from "./savedPost.service";

const savePost = catchAsync(async (req: Request, res: Response) => {
  if (!req.user) throw new AppError(status.UNAUTHORIZED, "User not authenticated");

  const payload = {
    postId: req.body.postId,
    userId: req.user?._id,
  };

  const saved = await SavedPostServices.savePost(payload);

  sendResponse(res, {
    statusCode: status.CREATED,
    success: true,
    message: "Post saved successfully",
    data: saved,
  });

});


const getSavedById = catchAsync(async (req: Request, res: Response) => {
  const saved = await SavedPostServices.getSavedById(req.params.id);

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: "Saved post retrieved",
    data: saved,
  });
});

const getSavedByUser = catchAsync(async (req: Request, res: Response) => {

  const user = req.user as JwtPayload;
  const userId = user._id;

  const data = await SavedPostServices.getSavedByUser(userId);

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: "Saved posts retrieved",
    data,
  });
});

const deleteSaved = catchAsync(async (req: Request, res: Response) => {
  if (!req.user) throw new AppError(status.UNAUTHORIZED, "User not authenticated");

  const user = req.user as JwtPayload;

  await SavedPostServices.deleteSaved(req.params.id, user);

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: "Saved post deleted",
    data: null,
  });
});

export const SavedPostController = {
  savePost,
  getSavedById,
  getSavedByUser,
  deleteSaved,
};
