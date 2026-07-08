import { Router } from "express";
import auth from "../../app/middleware/auth";
import { USER_ROLE } from "../User/user.constant";
import { StoryReplyController } from "./reply.controller";

const router = Router();

router.post("/", auth(USER_ROLE.user, USER_ROLE.admin), StoryReplyController.createReply);
router.get("/story/:storyId", StoryReplyController.getRepliesByStory);
router.get("/user/:userId", StoryReplyController.getRepliesByUser);
router.delete("/:id", auth(USER_ROLE.user, USER_ROLE.admin), StoryReplyController.deleteReply);

export const StoryReplyRoutes = router;
