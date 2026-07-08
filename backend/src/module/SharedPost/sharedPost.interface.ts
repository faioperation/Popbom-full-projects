import { Schema } from "mongoose";

export type TSharingPlatform = 'facebook' | 'tiktok' | 'whatsapp' | 'happy' | 'angry';

export interface ISharedPost {
  postId: Schema.Types.ObjectId;
  userId: Schema.Types.ObjectId;
  sharingPlatform: TSharingPlatform;
  createdAt: Date;
  updatedAt: Date;
}
