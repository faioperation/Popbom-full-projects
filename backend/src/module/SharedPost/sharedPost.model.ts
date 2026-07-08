import { model, Schema } from "mongoose";
import { ISharedPost, TSharingPlatform } from "./sharedPost.interface";

const sharedPostSchema = new Schema<ISharedPost>(
  {
    postId: { type: Schema.Types.ObjectId, ref: "Post", required: true },
    userId: { type: Schema.Types.ObjectId, ref: "User", required: true },
    sharingPlatform: {
      type: String,
      enum: ['facebook', 'tiktok', 'whatsapp', 'happy', 'angry'],
      required: true,
    },
  },
  { timestamps: true }
);

export const SharedPost = model<ISharedPost>("SharedPost", sharedPostSchema);
