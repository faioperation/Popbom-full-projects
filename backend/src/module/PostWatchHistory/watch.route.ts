import { Router } from "express";
import auth from "../../app/middleware/auth";
import { USER_ROLE } from "../User/user.constant";
import { PostWatchController } from "./watch.controller";

const router = Router();

// view vedio
router.post("/record", auth(USER_ROLE.user, USER_ROLE.admin), PostWatchController.recordWatch);

// Get watch history by user (paginated)
router.get("/user/:userId", auth(USER_ROLE.user, USER_ROLE.admin), PostWatchController.getWatchesByUser);

// Get watch records by post (paginated)
router.get("/post/:postId", PostWatchController.getWatchesByPost);

// Get single record
router.get("/:id", auth(USER_ROLE.user, USER_ROLE.admin), PostWatchController.getWatchById);

// Delete (owner or admin)
router.delete("/:id", auth(USER_ROLE.user, USER_ROLE.admin), PostWatchController.deleteWatch);

export const PostWatchRoutes = router;
