
import { model, Schema } from 'mongoose';

const pointHistorySchema = new Schema({
  userId: { type: Schema.Types.ObjectId, ref: 'User', required: true },
  change: { type: Number, required: true }, // positive or negative
  reason: { type: String, required: true }, // e.g. 'gift_received', 'gift_revoked', 'initial'
  sourceType: { type: String }, // 'gift', 'manual'
  sourceId: { type: Schema.Types.ObjectId }, // giftId if any
}, { timestamps: { createdAt: true, updatedAt: false } });

export const PointHistory = model('PointHistory', pointHistorySchema);
