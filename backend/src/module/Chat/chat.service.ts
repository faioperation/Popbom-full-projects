import mongoose, { Types } from "mongoose";
import { Conversation } from "./conversation.model";
import { Message } from "./message.model";
import { NotificationService } from "../Notification/notification.service";
/**
 * ChatService (hybrid pattern)
 * - create/find conversations
 * - create messages (transactional)
 * - fetch messages (with pagination cursor)
 * - mark messages read
 */

const findOrCreateConversation = async (userA: string, userB: string) => {
  const a = new Types.ObjectId(userA);
  const b = new Types.ObjectId(userB);

  // find existing 1:1 conversation
  let conv = await Conversation.findOne({
    participants: { $all: [a, b], $size: 2 },
  });

  if (!conv) {
    conv = await Conversation.create({ participants: [a, b] });
  }

  return conv;
};

const createMessage = async (payload: {
  conversationId: string;
  senderId: string;
  receiverId: string;
  text?: string;
  mediaUrl?: string | null;
}) => {

  try {
    const msgDocs = await Message.create(
      [
        {
          conversationId: new Types.ObjectId(payload.conversationId),
          senderId: new Types.ObjectId(payload.senderId),
          receiverId: new Types.ObjectId(payload.receiverId),
          text: payload.text || "",
          mediaUrl: payload.mediaUrl || null,
          isReadBy: [new Types.ObjectId(payload.senderId)],
        },
      ],

    );

    const msg = msgDocs[0];

    // update conversation metadata
    await Conversation.findByIdAndUpdate(
      payload.conversationId,
      {
        lastMessage: payload.text || (payload.mediaUrl ? "Media" : ""),
        lastMessageAt: new Date(),
      },

    );

    await NotificationService.sendNotification({
      userId: payload.receiverId,
      senderId: payload.senderId,
      type: 'message',
      message: payload.text || 'sent you a message',
      linkType: 'chat',
      linkId: payload.conversationId,
    });

    return await Message.findById(msg._id).populate({
      path: "senderId receiverId",
      select: "username",
      populate: {
        path: "userDetails",
        select: "photo",
      },
    });
  } catch (err) {
    throw err;
  }
};

const getMessages = async (conversationId: string, limit = 50, before?: string) => {
  const filter: any = { conversationId };
  if (before) {
    // treat `before` as message _id cursor
    filter._id = { $lt: before };
  }

  const messages = await Message.find(filter)
    .sort({ createdAt: -1 })
    .limit(limit)
    .populate({
      path: "senderId",
      select: "username",
      populate: {
        path: "userDetails",
        select: "photo",
      },
    })
    .lean();

  // return in ascending order for UI convenience
  return messages.reverse();
};

const markMessagesRead = async (conversationId: string, userId: string) => {
  await Message.updateMany(
    { conversationId, isReadBy: { $ne: new Types.ObjectId(userId) } },
    { $addToSet: { isReadBy: new Types.ObjectId(userId) } }
  );
  return true;
};

const getConversationsForUser = async (userId: string) => {
  const convs = await Conversation.find({ participants: userId })
    .sort({ lastMessageAt: -1 })
    .populate({
      path: "participants",
      select: "username",
      populate: {
        path: "userDetails",
        select: "photo",
      },
    })
    .lean();

  return convs;
};

export const ChatService = {
  findOrCreateConversation,
  createMessage,
  getMessages,
  markMessagesRead,
  getConversationsForUser,
};
