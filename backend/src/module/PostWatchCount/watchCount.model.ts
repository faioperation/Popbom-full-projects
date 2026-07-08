import { model, Schema } from "mongoose";
import { IPostWatchCount } from "./watchCount.interface";

const postWatchCountSchema = new Schema<IPostWatchCount>(
  {
    postId: { type: Schema.Types.ObjectId, ref: "Post", required: true, unique: true, index: true },
    watchCount: { type: Number, default: 0 },
  },
  { timestamps: true }
);

export const PostWatchCount = model<IPostWatchCount>("PostWatchCount", postWatchCountSchema);
