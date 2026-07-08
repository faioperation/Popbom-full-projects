import { Schema } from "mongoose";

export interface IChallengeRules {
  challengeId: Schema.Types.ObjectId;
  rule:string;
}