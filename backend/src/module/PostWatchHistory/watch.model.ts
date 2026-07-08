import { model, Schema } from "mongoose";
import { IPostWatch } from "./watch.interface";

const postWatchSchema = new Schema<IPostWatch>(
    {
        userId:{type: Schema.Types.ObjectId, ref:"User", required:true, index:true },
        postId: { type: Schema.Types.ObjectId, ref:"Post", required:true, index:true },
        count: { type:Number, default:1 },
    },
    {
        timestamps:true
    }
);

postWatchSchema.index({userId:1, postId:1}, { unique:true });

export const PostWatch = model<IPostWatch>("PostWatch", postWatchSchema);

// this model stands to see how much user(unique) view this