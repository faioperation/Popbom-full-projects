import { catchAsync } from "../../app/utils/catchAsync";
import sendResponse from "../../app/utils/sendResponse";
import status from "http-status";
import { StoryReactionServices } from "./reaction.service";

const reactToStory = catchAsync(async (req, res) => {
  if (!req.user) throw new Error("User not authenticated");
  const data = { ...req.body, userId: req.user.id };
  const reaction = await StoryReactionServices.reactToStory(data);

  sendResponse(res, {
    statusCode: status.CREATED,
    success: true,
    message: "Reaction added/updated",
    data: reaction,
  });
});

const getReactionsByStory = catchAsync(async (req, res) => {
  const reactions = await StoryReactionServices.getReactionsByStory(req.params.storyId);

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: "Reactions retrieved successfully",
    data: reactions,
  });
});

const getReactionsByUser = catchAsync(async (req, res) => {
  const reactions = await StoryReactionServices.getReactionsByUser(req.params.userId);

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: "User reactions retrieved successfully",
    data: reactions,
  });
});

const deleteReaction = catchAsync(async (req, res) => {
  if (!req.user) throw new Error("User not authenticated");
  await StoryReactionServices.deleteReaction(req.params.id, req.user.id);

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: "Reaction deleted successfully",
    data: null,
  });
});

export const StoryReactionController = {
  reactToStory,
  getReactionsByStory,
  getReactionsByUser,
  deleteReaction,
};
