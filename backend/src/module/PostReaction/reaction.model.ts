import { model, Schema } from "mongoose";
import { IPostReaction } from "./reaction.interface";


const postReactionSchema = new Schema<IPostReaction>(
    {
        postId:{ type: Schema.Types.ObjectId, ref:'Post', required:true},
        userId:{ type: Schema.Types.ObjectId, ref:"User", required:true },
        reaction:{
            type: String,
            enum: ['heart', 'like', 'sad', 'happy','angry'],
            required: true
        },
        challengeId: { type: Schema.Types.ObjectId, ref:'Challenge' }
    },
    { timestamps: true }
);

export const PostReaction = model<IPostReaction>('PostReaction',postReactionSchema);