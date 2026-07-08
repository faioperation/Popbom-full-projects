import { model, Schema } from "mongoose";
import { IStory } from "./story.interface";

const storySchema = new Schema<IStory>(
  {
    authorId: { type: Schema.Types.ObjectId, ref: "User", required: true },
    postId: { type: Schema.Types.ObjectId, ref: "Post", required: true },
    expiresAt: {
      type: Date,
      default: () => new Date(Date.now() + 24 * 60 * 60 * 1000), // auto-expire after 24h
    },
  },
  { timestamps: { createdAt: true, updatedAt: false } }
);

// TTL index to auto-delete expired stories
storySchema.index({ expiresAt: 1 }, { expireAfterSeconds: 0 });

export const Story = model<IStory>("Story", storySchema);
