import { model, Schema } from "mongoose";
import { IStoryReply } from "./reply.interface";

const storyReplySchema = new Schema<IStoryReply>(
  {
    storyId: { type: Schema.Types.ObjectId, ref: "Story", required: true, index: true },
    authorUserId: { type: Schema.Types.ObjectId, ref: "User", required: true },
    replyUserId: { type: Schema.Types.ObjectId, ref: "User", required: true },
    replyMessage: { type: String, required: true },
  },
  { timestamps: true }
);

export const StoryReply = model<IStoryReply>("StoryReply", storyReplySchema);
