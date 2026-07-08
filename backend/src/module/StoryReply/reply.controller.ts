import { catchAsync } from "../../app/utils/catchAsync";
import sendResponse from "../../app/utils/sendResponse";
import status from "http-status";
import { StoryReplyServices } from "./reply.service";

const createReply = catchAsync(async (req, res) => {
    if (!req.user) throw new Error("User not authenticated");

    const data = {
        ...req.body,
        replyUserId: req.user.id
    };
    const reply = await StoryReplyServices.createReply(data);

    sendResponse(res, {
        statusCode: status.CREATED,
        success: true,
        message: "Reply created",
        data: reply,
    });
});

const getRepliesByStory = catchAsync(async (req, res) => {
    const replies = await StoryReplyServices.getRepliesByStory(req.params.storyId);

    sendResponse(res, {
        statusCode: status.OK,
        success: true,
        message: "Replies retrieved successfully",
        data: replies,
    });
});

const getRepliesByUser = catchAsync(async (req, res) => {
    const replies = await StoryReplyServices.getRepliesByUser(req.params.userId);

    sendResponse(res, {
        statusCode: status.OK,
        success: true,
        message: "User replies retrieved successfully",
        data: replies,
    });
});

const deleteReply = catchAsync(async (req, res) => {
    if (!req.user) throw new Error("User not authenticated");

    await StoryReplyServices.deleteReply(req.params.id, req.user.id, req.user.role);

    sendResponse(res, {
        statusCode: status.OK,
        success: true,
        message: "Reply deleted successfully",
        data: null,
    });
});

export const StoryReplyController = {
    createReply,
    getRepliesByStory,
    getRepliesByUser,
    deleteReply,
};
