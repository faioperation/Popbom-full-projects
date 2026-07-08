import { Schema } from "mongoose";

export interface IStory {
  authorId: Schema.Types.ObjectId;
  postId: Schema.Types.ObjectId;
  createdAt: Date;
  expiresAt: Date;
}
