import { Schema } from "mongoose";

export type TReactionType = 'heart' | 'like' | 'sad' | 'happy' | 'angry';

export interface IPostReaction {
    postId: Schema.Types.ObjectId;
    userId: Schema.Types.ObjectId;
    reaction: TReactionType;
    challengeId?:Schema.Types.ObjectId;
    createdAt?: Date;
    updatedAt?: Date;
}