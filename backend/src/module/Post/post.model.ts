import { model, Schema } from "mongoose";
import { IPost } from "./post.interface";

const postSchema = new Schema<IPost>(
  {
    title: { type: String },
    body: { type: String },
    authorId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
    challengeId: { type: Schema.Types.ObjectId, ref: 'Challenge' },
    videoUrl: { type: String, required: true },
    musicUrl: { type: String },
    location: { type: String },
    status: { type: String, enum: ['active', 'banned', 'hide'], default: 'active' },
    audience: { type: String, enum: ['everyone', 'follower'], default: 'everyone' },
    postType: { type: String, enum: ['reels', 'challenges', 'story'], required: true },
  },
  { timestamps: true }
);

export const Post = model<IPost>('Post', postSchema);