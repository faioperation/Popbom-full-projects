import { Schema } from "mongoose";


export interface IPostWatch {
    userId: Schema.Types.ObjectId;
    postId: Schema.Types.ObjectId;
    count: number;
    createdAt: Date;
    updatedAt: Date;
};