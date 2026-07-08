import { model, Schema } from 'mongoose';
import { IFollow } from './follow.interface';
import { FOLLOW_STATUS } from './follow.constant';

const followSchema = new Schema<IFollow>(
  {
    followingUserId: { 
      type: Schema.Types.ObjectId, 
      ref: 'User', 
      required: true, 
      index: true 
    },

    followedUserId: { 
      type: Schema.Types.ObjectId, 
      ref: 'User', 
      required: true, 
      index: true 
    },
    status: { 
      type: String, 
      enum: FOLLOW_STATUS, 
      default: 'follow' 
    }

  },
  { timestamps: true }
);

// Compound unique index to prevent duplicate follows
followSchema.index({ followingUserId: 1, followedUserId: 1 }, { unique: true });

export const Follow = model<IFollow>('Follow', followSchema);
