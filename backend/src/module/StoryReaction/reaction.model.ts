import { model, Schema } from "mongoose";
import { IStoryReaction } from "./reaction.interface";

const storyReactionSchema = new Schema<IStoryReaction>(
  {
    storyId: { type: Schema.Types.ObjectId, ref: "Story", required: true, index: true },
    userId: { type: Schema.Types.ObjectId, ref: "User", required: true, index: true },
    reaction: { type: String, enum: ['heart','like','sad','happy','angry'], required: true },
  },
  { timestamps: true }
);

storyReactionSchema.index({ storyId: 1, userId: 1 }, { unique: true });

export const StoryReaction = model<IStoryReaction>("StoryReaction", storyReactionSchema);
