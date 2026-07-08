import { Schema } from "mongoose";

export interface IStoryReply {
    storyId: Schema.Types.ObjectId;
    authorUserId: Schema.Types.ObjectId; // who created the story
    replyUserId: Schema.Types.ObjectId;  // who is replying
    replyMessage: string;
    createdAt: Date;
    updatedAt: Date;
}
