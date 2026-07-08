import { model, Schema } from "mongoose";
import { IConversation } from "./chat.interface";

const conversationSchema = new Schema<IConversation>(
  {
    participants: [{ type: Schema.Types.ObjectId, ref: "User", required: true }],
    lastMessage: { type: String, default: "" },
    lastMessageAt: { type: Date, default: null },
  },
  { timestamps: true }
);

// index to help find 1:1 conv quickly
conversationSchema.index({ participants: 1 });

export const Conversation = model<IConversation>("Conversation", conversationSchema);
