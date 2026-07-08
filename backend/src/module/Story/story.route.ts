import { Router } from "express";
import auth from "../../app/middleware/auth";
import { USER_ROLE } from "../User/user.constant";
import { StoryController } from "./story.controller";

const router = Router();


router.get("/", auth(USER_ROLE.user, USER_ROLE.admin), StoryController.getFeed); //ok

router.get("/user/:userId", StoryController.getUserStories); //ok

router.get("/user",auth(USER_ROLE.user, USER_ROLE.admin), StoryController.getLoggedInUserStory);

router.delete("/:id", auth(USER_ROLE.user, USER_ROLE.admin), StoryController.deleteStory);

export const StoryRoutes = router;
