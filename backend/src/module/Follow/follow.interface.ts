import { Schema } from "mongoose";

export type TFollowStatus = 'follow' | 'unfollow';

export interface IFollow {
    followingUserId: Schema.Types.ObjectId; //who follows
    followedUserId: Schema.Types.ObjectId; //target
    status:TFollowStatus,
    createdAt:Date;
    updatedAt:Date;
}