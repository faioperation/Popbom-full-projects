import { Request, Response } from "express";
import { catchAsync } from "../../app/utils/catchAsync";
import sendResponse from "../../app/utils/sendResponse";
import status from "http-status";
import { ChatService } from "./chat.service";
import { Conversation } from "./conversation.model";
import { io } from "../../server";


const startConversation = catchAsync(async (req: Request, res: Response) => {
  const me = (req.user as any).id;
  const other = String(req.body.otherUserId || "");
  if (!other) {
    return sendResponse(res, {
      statusCode: status.BAD_REQUEST,
      success: false,
      message: "otherUserId is required",
    });
  }

  const conv = await ChatService.findOrCreateConversation(me, other);

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: "Conversation ready",
    data: conv,
  });
});

const getConversations = catchAsync(async (req: Request, res: Response) => {
  const me = (req.user as any).id;
  const convs = await ChatService.getConversationsForUser(me);
  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: "Conversations fetched",
    data: convs,
  });
});

const getMessages = catchAsync(async (req: Request, res: Response) => {
  const convId = req.params.conversationId;
  const limit = Number(req.query.limit) || 50;
  const before = String(req.query.before || "");
  const messages = await ChatService.getMessages(convId, limit, before);
  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: "Messages fetched",
    data: messages,
  });
});

const sendMessage = catchAsync(async (req: Request, res: Response) => {
  const me = (req.user as any).id;
  const { conversationId, toUserId, text, mediaUrl } = req.body;

  let convId = conversationId;
  let receiverId = toUserId;

  if (!convId) {
    if (!toUserId) {
      return sendResponse(res, {
        statusCode: status.BAD_REQUEST,
        success: false,
        message: "conversationId or toUserId required",
      });
    }
    const conv = await ChatService.findOrCreateConversation(me, toUserId);
    convId = conv._id.toString();
    receiverId = toUserId;
  }

  if (!receiverId) {
    const conv = await Conversation.findById(convId).lean();
    if (!conv) {
      return sendResponse(res, {
        statusCode: status.NOT_FOUND,
        success: false,
        message: "Conversation not found",
      });
    }
    receiverId = conv.participants
      .map((p: any) => p.toString())
      .find((id: string) => id !== me);
  }
  // persist message
  const message = await ChatService.createMessage({
    conversationId: convId,
    senderId: me,
    receiverId: receiverId!,
    text,
    mediaUrl,
  });

  // Emit Socket.IO events for real-time delivery
  if (io) {
    // Emit to conversation room
    io.to(`conversation_${convId}`).emit("chat:receive", { conversationId: convId, message });

    // Notify other participant(s) in personal room(s) for push/notification UI
    const conv = await Conversation.findById(convId).lean();
    if (conv && conv.participants) {
      conv.participants.forEach((p: any) => {
        const pid = p.toString();
        if (pid !== me) {
          io.to(`user_${pid}`).emit("notification:new_message", { conversationId: convId, message });
        }
      });
    }
  }

  sendResponse(res, {
    statusCode: status.CREATED,
    success: true,
    message: "Message sent",
    data: { conversationId: convId, message },
  });
});

const markRead = catchAsync(async (req: Request, res: Response) => {
  const convId = req.params.conversationId;
  const me = (req.user as any).id;
  await ChatService.markMessagesRead(convId, me);

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: "Marked read",
    data: null,
  });
});

export const ChatController = {
  startConversation,
  getConversations,
  getMessages,
  sendMessage,
  markRead,
};
