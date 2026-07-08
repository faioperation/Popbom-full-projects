import { catchAsync } from "../../app/utils/catchAsync";
import sendResponse from "../../app/utils/sendResponse";
import status from "http-status";
import { StoryServices } from "./story.service";
import { JwtPayload } from "jsonwebtoken";


// this is wrong need to correction
const getLoggedInUserStory = catchAsync(async (req, res) => {
  const user  = req.user as JwtPayload;
  const userId = user.id;
  
  const story = await StoryServices.getStoriesByUser(userId);

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: "Story retrieved",
    data: story,
  });
});

// get story by userId
const getUserStories = catchAsync(async (req, res) => {
  const stories = await StoryServices.getStoriesByUser(req.params.userId);

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: "User stories retrieved",
    data: stories,
  });
});

const getFeed = catchAsync(async (req, res) => {
   const user  = req.user as JwtPayload;
  const userId = user._id;

  const stories = await StoryServices.getFeed(userId);

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    data: stories,
  });
});

const deleteStory = catchAsync(async (req, res) => {
  await StoryServices.deleteStory(req.params.id, req.user as JwtPayload);

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: "Story deleted",
    data: null,
  });
});

export const StoryController = {
  getLoggedInUserStory,
  getUserStories,
  getFeed,
  deleteStory,
};
