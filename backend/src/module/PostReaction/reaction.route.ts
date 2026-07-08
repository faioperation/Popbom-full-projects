import { Router } from "express";
import auth from "../../app/middleware/auth";
import { USER_ROLE } from "../User/user.constant";
import { PostReactionController } from "./react.controller";

const router = Router();

router.post('/', auth(USER_ROLE.user, USER_ROLE.admin), PostReactionController.reactToPost);
router.get("/reactions/total/:userId", auth(USER_ROLE.user, USER_ROLE.admin), PostReactionController.getTotalReactionsOfAUser); //ok
router.get('/post/:postId', PostReactionController.getReactionsByPost);
router.get('/:userId', PostReactionController.getReactionsByUser);
router.delete('/:id', auth(USER_ROLE.user, USER_ROLE.admin), PostReactionController.deleteReaction);

export const PostReactionRoutes = router;