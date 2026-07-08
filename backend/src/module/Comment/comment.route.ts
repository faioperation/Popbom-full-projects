import { Router } from "express";
import auth from "../../app/middleware/auth";
import { USER_ROLE } from "../User/user.constant";
import { CommentController } from "./comment.controller";

const router = Router();

router.post("/", 
    auth(USER_ROLE.admin, USER_ROLE.user), 
    CommentController.createComment
);
router.get("/post/:postId", 
    CommentController.getCommentsByPost
);

router.patch("/:id",
    auth(USER_ROLE.admin, USER_ROLE.user),
    CommentController.updateComment
);
router.delete("/:id", 
    auth(USER_ROLE.user, USER_ROLE.admin),
    CommentController.deleteComment
);

export const CommentRoutes = router;