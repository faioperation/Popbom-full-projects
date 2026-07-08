import { Schema } from "mongoose";

export interface IChallengeParticipant {
    challengeId: Schema.Types.ObjectId;
    postId: Schema.Types.ObjectId;
    participantId: Schema.Types.ObjectId;
    createdAt: Date;
    updatedAt:Date;
}