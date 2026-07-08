import { Router } from "express";
import auth from "../../app/middleware/auth";
import { USER_ROLE } from "../User/user.constant";
import { PostWatchCountController } from "./watchCount.controller";

const router = Router();


router.post("/increment", auth(USER_ROLE.user), PostWatchCountController.incrementWatch);

router.get("/:postId", PostWatchCountController.getWatchCount);

router.patch("/set",     PostWatchCountController.setWatchCount);

router.delete("/:postId", auth(USER_ROLE.admin), PostWatchCountController.resetWatchCount);

export const PostWatchCountRoutes = router;
