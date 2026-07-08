import { Schema } from "mongoose";

export interface IPostTag {
    tagId: Schema.Types.ObjectId;
    postId: Schema.Types.ObjectId;
    createdAt?: Date;
    updatedAt?:Date;
}