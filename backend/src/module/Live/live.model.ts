import { model, Schema } from "mongoose";
import { ILive } from "./live.interface";

const liveSchema = new Schema<ILive>(
  {
    userId: {
      type: Schema.Types.ObjectId,
      ref: "User",
      required: true,
      index: true,
    },
    channel: {
      type: String,
      required: true,
      unique: true,
      index: true,
    },
    isLive: {
      type: Boolean,
      default: true,
      index: true,
    },
    startedAt: {
      type: Date,
      default: Date.now,
    },
    endedAt: {
      type: Date,
    },
    viewerCount: {
      type: Number,
      default: 0,
    },
  },
  {
    timestamps: true,
  }
);

// Index for efficient queries
liveSchema.index({ isLive: 1, createdAt: -1 });
liveSchema.index({ userId: 1, isLive: 1 });

export const Live = model<ILive>("Live", liveSchema);
