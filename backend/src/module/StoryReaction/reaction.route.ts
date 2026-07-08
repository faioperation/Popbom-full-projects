import { Router } from "express";
import auth from "../../app/middleware/auth";
import { USER_ROLE } from "../User/user.constant";
import { StoryReactionController } from "./reaction.controller";

const router = Router();

router.post("/", auth(USER_ROLE.user, USER_ROLE.admin), StoryReactionController.reactToStory);
router.get("/story/:storyId", StoryReactionController.getReactionsByStory);
router.get("/user/:userId", StoryReactionController.getReactionsByUser);
router.delete("/:id", auth(USER_ROLE.user, USER_ROLE.admin), StoryReactionController.deleteReaction);

export const StoryReactionRoutes = router;
