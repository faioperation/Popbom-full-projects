import { model, Schema } from "mongoose";
import { IMessage } from "./chat.interface";


const messageSchema = new Schema<IMessage>(
  {
    conversationId: { type: Schema.Types.ObjectId, ref: "Conversation", required: true, index: true },
    senderId: { type: Schema.Types.ObjectId, ref: "User", required: true, index: true },
    receiverId:{ type: Schema.Types.ObjectId, ref:"User", required:true, index:true },
    text: { type: String, default: "" },
    mediaUrl: { type: String, default: null },
    isReadBy: [{ type: Schema.Types.ObjectId, ref: "User" }],
  },
  { timestamps: true }
);

messageSchema.index({ conversationId: 1, createdAt: -1 });

export const Message = model<IMessage>("Message", messageSchema);
