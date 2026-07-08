import { Schema } from "mongoose";

export interface IPostWatchCount {
  postId: Schema.Types.ObjectId;
  watchCount: number;
  createdAt: Date;
  updatedAt: Date;
}
