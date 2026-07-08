import { model, Schema } from "mongoose";
import { IGift } from "./gift.interface";

const giftSchema = new Schema<IGift>(
  {
    authorId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
    userId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
    giftType: { type: String, enum: ['coin','heart','rose','star','fire'], required: true },
  },
  { timestamps: { createdAt: true, updatedAt: false } }
);

export const Gift = model<IGift>('Gift', giftSchema);
