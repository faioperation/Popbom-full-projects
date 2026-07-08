import { catchAsync } from "../../app/utils/catchAsync";
import sendResponse from "../../app/utils/sendResponse";
import status from "http-status";
import { CommentServices } from "./comment.service";
import { JwtPayload } from "jsonwebtoken";

const createComment = catchAsync(async (req, res) => {
  const data = { ...req.body, userId: req.user?.id };
  const comment = await CommentServices.createComment(data);

  sendResponse(res, {
    statusCode: status.CREATED,
    success: true,
    message: "Comment created",
    data: comment,
  });
});

const getCommentsByPost = catchAsync(async (req, res) => {
  const { postId } = req.params;
  const comments = await CommentServices.getCommentsByPost(postId);

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: "Comments retrieved successfully",
    data: comments,
  });
});

const updateComment = catchAsync(async (req, res) => {
  const comment = await CommentServices.updateComment(req.params.id, req.user as JwtPayload, req.body);

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: "Comment updated successfully",
    data: comment,
  });
});
  
const deleteComment = catchAsync(async (req, res) => {
  await CommentServices.deleteComment(req.params.id, req.user as JwtPayload);

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: "Comment deleted successfully",
    data: null,
  });
});

export const CommentController = {
  createComment,
  getCommentsByPost,
  updateComment,
  deleteComment,
};
