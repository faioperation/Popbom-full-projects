import { Types } from "mongoose";
import AppError from "../../app/errors/AppError";
import status from "http-status";
import { TReactionType } from "./reaction.interface";
import { StoryReaction } from "./reaction.model";
import { Story } from "../Story/story.model";

interface IReactPayload {
    storyId: Types.ObjectId | string;
    userId: Types.ObjectId | string;
    reaction: TReactionType;
}

// Add or update reaction
const reactToStory = async (data: IReactPayload) => {
  // i
  const story = await Story.findById(data.storyId);
  if (!story) throw new AppError(status.NOT_FOUND, "Story not found");
  const existing = await StoryReaction.findOne({ storyId: data.storyId, userId: data.userId });
  if (existing) {
    existing.reaction = data.reaction;
    return existing.save();
  }
  const reaction = await StoryReaction.create(data);
  return reaction;
};

  // Get reactions for a story
  const getReactionsByStory = async (storyId: string) => {
    return StoryReaction.find({ storyId }).populate("userId", "name photo username");
  };

// Get reactions by a user
const getReactionsByUser = async (userId: string) => {
  return StoryReaction.find({ userId }).populate("storyId", "authorId createdAt");
};

// Delete reaction (only owner)
const deleteReaction = async (reactionId: string, userId: string) => {
  const reaction = await StoryReaction.findOne({ _id: reactionId, userId });
  if (!reaction) throw new AppError(status.NOT_FOUND, "Reaction not found or unauthorized");
  await reaction.deleteOne();
  return true;
};

export const StoryReactionServices = {
  reactToStory,
  getReactionsByStory,
  getReactionsByUser,
  deleteReaction,
};
