import { SharedPost } from "./sharedPost.model";
import { ISharedPost } from "./sharedPost.interface";
import { NotificationService } from "../Notification/notification.service";
import { Post } from "../Post/post.model";

const createSharedPost = async (data: Partial<ISharedPost>) => {
  const sharedPost = await SharedPost.create(data);

  if (sharedPost) {
    const post = await Post.findById(data.postId);
    await NotificationService.sendNotification({
      userId: post?.authorId as any,
      senderId: data.userId as any,
      type: 'share',
      message: 'shared your post',
      linkType: 'post',
      linkId: data.postId as any,
    });
  }

  return sharedPost;
};

const getSharedPostsByPost = async (postId: string) => {
  return await SharedPost.find({ postId }).populate("userId", "name photo");
};

const getSharedPostsByUser = async (userId: string) => {
  return await SharedPost.find({ userId }).populate("postId", "title videoUrl createdAt");
};

export const SharedPostServices = {
  createSharedPost,
  getSharedPostsByPost,
  getSharedPostsByUser,
};