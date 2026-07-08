import { Schema } from "mongoose";

export interface IUserDetails {
  userId: Schema.Types.ObjectId;
  name: string;
  photo?: string | null;
  bio?: string;
  instaLink?: string;
  youtubeLink?: string;
  createdAt?: Date;
  updatedAt?: Date;
  deletedAt?: Date | null;
}
