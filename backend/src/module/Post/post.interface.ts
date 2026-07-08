import { Schema } from "mongoose";

export type TPostStatus = 'active' | 'banned' | 'hide';
export type TPostAudience = 'everyone' | 'follower';
export type TPostType = 'reels' | 'challenges' | 'story';

export interface IPost {
  title?: string;
  body?: string;
  authorId: Schema.Types.ObjectId;
  challengeId?:Schema.Types.ObjectId;
  videoUrl: string;
  musicUrl?: string;
  location?: string;
  status: TPostStatus;
  audience: TPostAudience;
  postType: TPostType;
  createdAt: Date;
  updatedAt: Date;
}

export interface CreatePostInput {
  title?: string;
  body?: string;
  authorId: string;
  challengeId?: string;
  videoUrl: string;
  musicUrl?: string;
  location?: string;
  postType: TPostType;
  audience?: TPostAudience;
  hashTagIds?: string[];
  tagPeople?: string[];
}