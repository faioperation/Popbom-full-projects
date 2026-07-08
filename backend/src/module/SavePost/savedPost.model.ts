import { model, Schema } from "mongoose";
import { ISavedPost } from "./savedPost.interface";

const savedPostSchema = new Schema<ISavedPost>(
  {
    postId: { type: Schema.Types.ObjectId, ref: "Post", required: true, index: true },
    authorId: { type: Schema.Types.ObjectId, ref: "User", required: true, index: true },
    userId: { type: Schema.Types.ObjectId, ref: "User", required: true, index: true },
  },
  { timestamps: true }
);

// Add a compound unique index so a user can't save the same post twice
// study krte hba
savedPostSchema.index({ postId: 1, userId: 1 }, { unique: true });

export const SavedPost = model<ISavedPost>("SavedPost", savedPostSchema);
