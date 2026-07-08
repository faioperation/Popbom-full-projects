import { Router } from "express";
import { ChatController } from "./chat.controller";
import auth from "../../app/middleware/auth";
import { USER_ROLE } from "../User/user.constant";

const router = Router();

router.post("/start", auth(USER_ROLE.user, USER_ROLE.admin), ChatController.startConversation);
router.get("/", auth(USER_ROLE.user, USER_ROLE.admin), ChatController.getConversations);
router.get("/:conversationId/messages", auth(USER_ROLE.user, USER_ROLE.admin), ChatController.getMessages);

// send message via HTTP (hybrid) - server will still emit via socket after save
router.post("/send", auth(USER_ROLE.user, USER_ROLE.admin), ChatController.sendMessage);

// mark read
router.patch("/:conversationId/read", auth(USER_ROLE.user, USER_ROLE.admin), ChatController.markRead);

export const ChatRoutes = router;
