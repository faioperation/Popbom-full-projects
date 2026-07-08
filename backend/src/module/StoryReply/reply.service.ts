
import { Types } from "mongoose";
import AppError from "../../app/errors/AppError";
import status from "http-status";
import { StoryReply } from "./reply.model";
import { ChatService } from "../Chat/chat.service";

interface IReplyPayload {
    storyId: Types.ObjectId | string;
    authorUserId: Types.ObjectId | string;
    replyUserId: Types.ObjectId | string;
    replyMessage: string;
}

// Create a reply
const createReply = async (data: IReplyPayload) => {
    // check this reply is from the same user
    if (data.replyUserId.toString() === data.authorUserId.toString()) {
        throw new AppError(status.BAD_REQUEST, "You cannot reply to your own story");
    }
    const result = await StoryReply.create(data);

    // Send message to author's inbox
    if (result) {
        const conversation = await ChatService.findOrCreateConversation(
            data.replyUserId.toString(),
            data.authorUserId.toString()
        );

        if (conversation) {
            await ChatService.createMessage({
                conversationId: conversation._id.toString(),
                senderId: data.replyUserId.toString(),
                receiverId: data.authorUserId.toString(),
                text: data.replyMessage,
            });
        }
    }

    return result;
};

// Get replies for a story
const getRepliesByStory = async (storyId: string) => {
    return StoryReply.find({ storyId })
        .populate("replyUserId", "name photo username")
        .populate("authorUserId", "name photo username")
        .populate({
            path: "storyId",
            populate: {
                path: "postId",
                select: "videoUrl",
            },
        })
        .sort({ createdAt: -1 });
};

// Get replies by a user
const getRepliesByUser = async (userId: string) => {
    return StoryReply.find({ replyUserId: userId })
        .sort({ createdAt: -1 })
        .populate({
            path: "storyId",
            select: "authorId createdAt postId",
            populate: {
                path: "postId",
                select: "videoUrl",
            },
        })
        .populate("authorUserId", "name photo username");
};

// Delete a reply (only reply owner or admin)
const deleteReply = async (replyId: string, userId: string, userRole: string) => {
    const reply = await StoryReply.findById(replyId);
    if (!reply) throw new AppError(status.NOT_FOUND, "Reply not found");

    if (reply.replyUserId.toString() !== userId && userRole !== "admin") {
        throw new AppError(status.UNAUTHORIZED, "You are not authorized to delete this reply");
    }

    await StoryReply.findByIdAndDelete(replyId);
    return true;
};

export const StoryReplyServices = {
    createReply,
    getRepliesByStory,
    getRepliesByUser,
    deleteReply,
};
