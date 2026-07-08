import { Schema } from "mongoose";

export type GiftType = 'coin' | 'heart' | 'rose' | 'star' | 'fire';

export interface IGift {
  authorId: Schema.Types.ObjectId; //who will send gift    sender
  userId: Schema.Types.ObjectId;  //who will get gift    receiver
  giftType: GiftType;
  createdAt?: Date;
}
