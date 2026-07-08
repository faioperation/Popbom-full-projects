import { Router } from "express";
import { SharedPostController } from "./sharedPost.controller";
import auth from "../../app/middleware/auth";
import { USER_ROLE } from "../User/user.constant";

const router = Router();

router.post(
  '/',
  auth(USER_ROLE.user, USER_ROLE.admin),
  SharedPostController.createSharedPost
);

router.get(
  '/:postId',
  SharedPostController.getSharedPostsByPost
);

router.get(
  '/user/:userId',
  SharedPostController.getSharedPostsByUser
);

export const SharedPostRoutes = router;
