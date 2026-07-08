import { model, Schema } from "mongoose";
import { IChallengeParticipant } from "./participant.interface";


const challengeParticipantSchema = new Schema<IChallengeParticipant>(
    {
        challengeId: { type: Schema.Types.ObjectId, ref:"Challenge", required: true },
        postId: { type: Schema.Types.ObjectId, ref:'Post', required:true },
        participantId: { type: Schema.Types.ObjectId, ref:"User", required:true },
    },
    {
        timestamps: true
    }
);

export const ChallengeParticipant = model<IChallengeParticipant>(
    "ChallengeParticipant",
    challengeParticipantSchema
);