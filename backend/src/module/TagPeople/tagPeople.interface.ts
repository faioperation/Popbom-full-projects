import { Schema } from 'mongoose';

export interface ITagPerson {
  postId: Schema.Types.ObjectId;
  userId: Schema.Types.ObjectId;
  commentId?: Schema.Types.ObjectId;
  createdAt?: Date;
  updatedAt?: Date;
}