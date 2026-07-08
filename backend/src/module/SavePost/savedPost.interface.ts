import { Schema } from "mongoose";

export interface ISavedPost {
    postId: Schema.Types.ObjectId;
    authorId: Schema.Types.ObjectId;
    userId: Schema.Types.ObjectId;
    createdAt: Date;
    updatedAt: Date;
}