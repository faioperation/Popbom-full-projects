import { model, Schema } from "mongoose";
import { IChallenge } from "./challenge.interface";

const challengeSchema = new Schema<IChallenge>(
  {
    authorId: { type: Schema.Types.ObjectId, ref: "User", required: true },
    challengeName: { type: String, required: true },
    challengeDesc: { type: String, required:true},
    challengePoster: { type: String },
    challengeStartDate: { type: Date, required: true },
    challengeEndDate: { type: Date, required: true },
  },
  { timestamps: true }
);

export const Challenge = model<IChallenge>("Challenge", challengeSchema);

