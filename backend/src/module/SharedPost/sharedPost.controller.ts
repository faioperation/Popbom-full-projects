import { catchAsync } from "../../app/utils/catchAsync";
import sendResponse from "../../app/utils/sendResponse";
import status from "http-status";
import { SharedPostServices } from "./sharedPost.service";

const createSharedPost = catchAsync(async (req, res) => {
  const data = { ...req.body, userId: req.user?.id };
  const sharedPost = await SharedPostServices.createSharedPost(data);

  sendResponse(res, {
    statusCode: status.CREATED,
    success: true,
    message: "Post shared successfully",
    data: sharedPost,
  });
});

const getSharedPostsByPost = catchAsync(async (req, res) => {
  const { postId } = req.params;
  const sharedPosts = await SharedPostServices.getSharedPostsByPost(postId);

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    data: sharedPosts,
  });
});

const getSharedPostsByUser = catchAsync(async (req, res) => {
  const { userId } = req.params;
  const sharedPosts = await SharedPostServices.getSharedPostsByUser(userId);

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    data: sharedPosts,
  });
});

export const SharedPostController = {
  createSharedPost,
  getSharedPostsByPost,
  getSharedPostsByUser,
};
