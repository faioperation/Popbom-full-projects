import { catchAsync } from "../../app/utils/catchAsync";
import sendResponse from "../../app/utils/sendResponse";
import status from "http-status";
import { PostReactionServices } from "./reaction.service";

const reactToPost = catchAsync(async (req, res) => {
  if (!req.user) throw new Error("User not authenticated");

  const data = { ...req.body, userId: req.user.id };
  const reaction = await PostReactionServices.reactToPost(data);

  sendResponse(res, {
    statusCode: status.CREATED,
    success: true,
    message: "Reaction added/updated",
    data: reaction,
  });
});

const getReactionsByPost = catchAsync(async (req, res) => {
  const reactions = await PostReactionServices.getReactionsByPost(req.params.postId);

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: "Reactions retrieved successfully",
    data: reactions,
  });
});

const getReactionsByUser = catchAsync(async (req, res) => {
  const reactions = await PostReactionServices.getReactionsByUser(req.params.userId);

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: "User reactions retrieved successfully",
    data: reactions,
  });
});

const deleteReaction = catchAsync(async (req, res) => {
  if (!req.user) throw new Error("User not authenticated");

  await PostReactionServices.deleteReaction(req.params.id, req.user.id);

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: "Reaction deleted successfully",
    data: null,
  });
});

const getTotalReactionsOfAUser = catchAsync(async (req, res) => {
  const userId = req.params.userId;

  const data = await PostReactionServices.getTotalReactionsOfAUser(userId);

  sendResponse(res, {
    statusCode: 200,
    success: true,
    message: "Total reactions retrieved",
    data
  });
});


export const PostReactionController = {
  reactToPost,
  getReactionsByPost,
  getReactionsByUser,
  deleteReaction,
  getTotalReactionsOfAUser
};