import { Schema, Types } from "mongoose";

export interface IConversation {
  participants: Types.ObjectId[];
  lastMessage?: string | null;
  lastMessageAt?: Date | null;
  createdAt?: Date;
  updatedAt?: Date;
}

export interface IMessage {
  conversationId: Types.ObjectId;
  senderId: Types.ObjectId;
  receiverId:Types.ObjectId;
  text?: string;
  mediaUrl?: string | null;
  isReadBy?: Types.ObjectId[];
  createdAt?: Date;
  updatedAt?: Date;
}