import { model, Schema } from "mongoose";
import { IPostTag } from "./postTag.interface";


const postTagSchema = new Schema<IPostTag>(
    {
        tagId: { type: Schema.Types.ObjectId, ref:'Tag', required:true},
        postId: { type: Schema.Types.ObjectId, ref:'Post', required:true},
    },
    {
        timestamps:true
    }
);

postTagSchema.index({tagId:1, postId:1}, {unique:true});

export const PostTag = model<IPostTag>('PostTag', postTagSchema);