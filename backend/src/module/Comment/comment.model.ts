import { model, Schema } from "mongoose";
import { IComment } from "./comment.interface";

const commentSchema = new Schema<IComment>(
  {
    postId: { type: Schema.Types.ObjectId, ref: "Post", required: true },
    userId: { type: Schema.Types.ObjectId, ref: "User", required: true },
    parentCommentId: { type: Schema.Types.ObjectId, ref: "Comment", default: null },
    comment: { type: String, required: true },
  },
  { timestamps: true }
);

export const Comment = model<IComment>("Comment", commentSchema);
