import { Schema } from "mongoose";

export type TReactionType = 'heart' | 'like' | 'sad' | 'happy' | 'angry';

export interface IStoryReaction {
    storyId: Schema.Types.ObjectId;
    userId: Schema.Types.ObjectId;
    reaction: TReactionType;
    createdAt: Date;
    updatedAt: Date;
}
