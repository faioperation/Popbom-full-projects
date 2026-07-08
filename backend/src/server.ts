
import mongoose from "mongoose";
import app from "./app";
import { Server as HttpServer } from "http";
import { Server as IOServer } from "socket.io";
import config from "./app/config";
import jwt from "jsonwebtoken";
import { ChatService } from "./module/Chat/chat.service";
import { Conversation } from "./module/Chat/conversation.model";
import "dotenv/config";

let server: HttpServer;
let io: IOServer;

async function main() {
  try {
    await mongoose.connect(config.database_url as string);

    server = app.listen(config.port, () => {
      console.log(`App listening on port http://localhost:${config.port}`);
    });

    io = new IOServer(server, {
      cors: {
        origin: "*",
        methods: ["GET", "POST"],
      },
    });

    // map userId -> Set(socketIds)
    const onlineMap = new Map<string, Set<string>>();

    // socket auth middleware (token via handshake.auth.token)
    io.use((socket, next) => {
      try {
        const token = (socket.handshake.auth && socket.handshake.auth.token) || (socket.handshake.query && socket.handshake.query.token);
        if (!token) return next(new Error("Auth token missing"));
        const raw = String(token).replace(/^Bearer\s+/i, "");
        const decoded = jwt.verify(raw, config.jwt_access_secret as string) as any;
        socket.data.user = decoded; // { id, email, role, ... }
        return next();
      } catch (err) {
        return next(new Error("Unauthorized"));
      }
    });

    io.on("connection", (socket) => {
      const user = socket.data.user as any;
      const userId = user?.id;
      console.log("Socket connected:", socket.id, "userId:", userId);

      if (userId) {
        // join personal room
        socket.join(`user_${userId}`);
        // maintain online map
        const set = onlineMap.get(userId) || new Set<string>();
        set.add(socket.id);
        onlineMap.set(userId, set);
      }

      // join conversation room (client opens a chat)
      socket.on("join_conversation", async ({ conversationId }: { conversationId: string }) => {
        if (!conversationId) return;
        socket.join(`conversation_${conversationId}`);
      });

      // socket fallback to send message (optional). Prefer REST /api/chat/send.
      socket.on("chat:send", async (payload: { conversationId?: string; toUserId?: string; text?: string; mediaUrl?: string }, ack) => {
        try {
          const senderId = userId;
          let conversationId = payload.conversationId;
          let receiverId = payload.toUserId;

          if (!conversationId) {
            if (!payload.toUserId) throw new Error("toUserId required");
            const conv = await ChatService.findOrCreateConversation(senderId, payload.toUserId);
            conversationId = conv._id.toString();
            receiverId = payload.toUserId;
          }

           if (!receiverId) {
        const conv = await Conversation.findById(conversationId).lean();
        if (!conv) throw new Error("Conversation not found");
        receiverId = conv.participants
          .map((p: any) => p.toString())
          .find((id: string) => id !== senderId);
      }

          const message = await ChatService.createMessage({
            conversationId,
            senderId,
            receiverId:receiverId!,
            text: payload.text,
            mediaUrl: payload.mediaUrl,
          });

          // Emit to conversation room
          io.to(`conversation_${conversationId}`).emit("chat:receive", { conversationId, message });

          // Notify other participant(s) in personal room(s) for push/notification UI
          const conv = await Conversation.findById(conversationId).lean();
          if (conv && conv.participants) {
            conv.participants.forEach((p: any) => {
              const pid = p.toString();
              if (pid !== senderId) {
                io.to(`user_${pid}`).emit("notification:new_message", { conversationId, message });
              }
            });
          }

          ack && ack(null, message);
        } catch (err: any) {
          console.error("chat:send error", err);
          ack && ack({ error: err.message || "send_failed" });
        }
      });

      // typing indicator
      socket.on("chat:typing", ({ conversationId, isTyping }: { conversationId: string; isTyping: boolean }) => {
        if (!conversationId) return;
        socket.to(`conversation_${conversationId}`).emit("chat:typing", { userId, conversationId, isTyping });
      });

      // mark read via socket
      socket.on("chat:read", async ({ conversationId }, ack) => {
        try {
          await ChatService.markMessagesRead(conversationId, userId);
          socket.to(`conversation_${conversationId}`).emit("chat:read", { userId, conversationId });
          ack && ack(null, { ok: true });
        } catch (err) {
          ack && ack({ error: "read_failed" });
        }
      });

      // ========== LIVE BROADCAST EVENTS ==========
      
      // Join live room
      socket.on("live:join", ({ liveId }: { liveId: string }) => {
        if (!liveId) return;
        socket.join(`live_${liveId}`);
        console.log(`User ${userId} joined live room: live_${liveId}`);
      });

      // Leave live room
      socket.on("live:leave", ({ liveId }: { liveId: string }) => {
        if (!liveId) return;
        socket.leave(`live_${liveId}`);
        console.log(`User ${userId} left live room: live_${liveId}`);
      });

      // Send live comment
      socket.on("live:comment", async (
        { liveId, comment }: { liveId: string; comment: string },
        ack
      ) => {
        try {
          if (!liveId || !comment || !comment.trim()) {
            throw new Error("Live ID and comment are required");
          }

          // Rate limiting: prevent spam (simple check - can be enhanced)
          // In production, use Redis for proper rate limiting

          // Get user details for comment
          const { User } = await import("./module/User/user.modal");
          const { UserDetails } = await import("./module/UserDetails/userDetails.model");
          
          const user = await User.findById(userId).select("username").lean();
          const userDetails = await UserDetails.findOne({ userId }).select("name photo").lean();

          const commentData = {
            userId,
            username: user?.username || "Unknown",
            name: userDetails?.name || "",
            photo: userDetails?.photo || "",
            comment: comment.trim(),
            timestamp: new Date(),
          };

          // Broadcast to all viewers in the live room
          io.to(`live_${liveId}`).emit("live:comment:new", {
            liveId,
            ...commentData,
          });

          ack && ack(null, { success: true, comment: commentData });
        } catch (err: any) {
          console.error("live:comment error", err);
          ack && ack({ error: err.message || "comment_failed" });
        }
      });

      socket.on("disconnect", () => {
        console.log("Socket disconnected:", socket.id, "userId:", userId);
        if (userId) {
          const set = onlineMap.get(userId);
          if (set) {
            set.delete(socket.id);
            if (set.size === 0) onlineMap.delete(userId);
            else onlineMap.set(userId, set);
          }
        }
      });
    });
  } catch (error) {
    console.error("Error starting server:", error);
  }
}

main();

// graceful shutdown handlers (keep yours)
process.on("unhandledRejection", (error) => {
  console.log(`unhandledRejection is detected, shutting down the server`);
  // if (server) {
  //   server.close(() => {
  //     process.exit(1);
  //   });
  // } else {
  //   process.exit(1);
  // }
});

process.on("uncaughtException", (error) => {
  console.log(`uncaughtException is detected, shutting down the server`);
  if (server) {
    server.close(() => {
      process.exit(1);
    });
  } else {
    process.exit(1);
  }
});

export { io };


// --------------------------------------


// import mongoose from 'mongoose';
// import app from './app';

// import { Server as HttpServer } from 'http';
// import { Server as IOServer } from 'socket.io';
// import config from './app/config';

// let server: HttpServer;
// let io: IOServer

// async function main() {
//   try {
//     await mongoose.connect(config.database_url as string);

//     server = app.listen(config.port, () => {
//       console.log(`App listening on port http://localhost:${config.port}`);
//     });

//     // initialize socket.IO
//     // io = new IOServer(server, {
//     //   cors:{
//     //     origin:'*',
//     //     methods:['GET','POST'],
//     //   },
//     // });
 
//     // io.on('connection', (socket) =>{
//     //   console.log('User connected',socket.id);

//     //   socket.on('join', (userId:string) =>{
//     //     socket.join(userId);
//     //     console.log(`Socket ${socket.id} joined room ${userId}`);
//     //   });

//     //   socket.on('disconnect',()=>{
//     //     console.log('User disconnected', socket.id);
//     //   });
//     // });

//   } catch (error) {
//     console.error('Error starting server:',error);
//   }
// }

// main();

// process.on('unhandledRejection', (error) => {
//   console.log(`unhandledRejection is detected, shutting down the server`);
//   if (server) {
//     server.close(() => {
//       process.exit(1);
//     });
//   } else {
//     process.exit(1);
//   }
// });

// process.on('uncaughtException', (error) => {
//   console.log(`uncaughtException is detected, shutting down the server`);
//   if (server) {
//     server.close(() => {
//       process.exit(1);
//     });
//   } else {
//     process.exit(1);
//   }
// });


// // export { io };

// // ---------------
// // for frontend implementation
// // import { io } from "socket.io-client";

// // const socket = io("http://localhost:10000", {
// //   auth: { token: "Bearer <ACCESS_TOKEN>" }
// // });

// // socket.on("connect", () => console.log("connected", socket.id));
// // -------------
// // socket.emit("find_or_create_1to1", { otherUserId: "<otherId>" }, (err, conv) => {
// //   if (!err) {
// //     const conversationId = conv._id;
// //     socket.emit("chat:send", { conversationId, text: "hello" }, (err, savedMessage) => {
// //       console.log("message saved", savedMessage);
// //     });
// //   }
// // });
// // --------------
// // socket.on("chat:receive", ({ conversationId, message }) => {
// //   console.log("new message", conversationId, message);
// // });
