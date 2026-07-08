import { Request, Response } from "express";
import { catchAsync } from "../../app/utils/catchAsync";
import sendResponse from "../../app/utils/sendResponse";
import status from "http-status";
import { TagService } from "./tag.service";

const createTag = catchAsync(async (req: Request, res: Response) => {
  const result = await TagService.createTag(req.body);

  sendResponse(res, {
    statusCode: status.CREATED,
    success: true,
    message: 'Tag created successfully',
    data: result
  });
});

const getAllTags = catchAsync(async (req: Request, res: Response) => {
  const result = await TagService.getAllTags();

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: 'Tags retrieved successfully',
    data: result
  });
});

export const TagController = {
  createTag,
  getAllTags
};