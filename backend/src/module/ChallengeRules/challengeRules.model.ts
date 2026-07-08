import { model, Schema } from "mongoose"
import { IChallengeRules } from "./challengeRules.interface"

const challengeRuleSchema = new Schema <IChallengeRules>(
  {
    challengeId: { type: Schema.Types.ObjectId, ref:"Challenge", required:true },
    rule: { type: String, required:true }
  }
)

export const ChallengeRule = model<IChallengeRules>('ChallengeRule', challengeRuleSchema)
