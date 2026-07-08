import { Schema, Types } from "mongoose";

export interface IComment {
  postId: Types.ObjectId;
  userId: Types.ObjectId;
  parentCommentId?: Types.ObjectId | null;
  comment: string;
  createdAt: Date;
  updatedAt: Date;
}
