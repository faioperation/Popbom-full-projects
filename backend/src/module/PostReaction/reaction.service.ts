import { Types } from "mongoose";
import { TReactionType } from "./reaction.interface";
import { PostReaction } from "./reaction.model";
import { NotificationService } from "../Notification/notification.service";
// import { io } from "../../server";
import { Post } from "../Post/post.model";

interface IReactPayload {
  postId: Types.ObjectId | string;
  userId: Types.ObjectId | string;
  reaction: TReactionType;
}

const reactToPost = async (data: IReactPayload) => {

  const post = await Post.findById(data.postId);
  if (!post) throw new Error("Post not found");

  const challengeId = post.challengeId;

  const reaction = await PostReaction.findOneAndUpdate(
    { postId: data.postId, userId: data.userId },
    { reaction: data.reaction, challengeId },
    { new: true, upsert: true, setDefaultsOnInsert: true }
  );

  // save notification in DB
  await NotificationService.sendNotification({
    userId: post.authorId as any,
    senderId: data.userId as any,
    type: "reaction",
    message: `reacted with ${data.reaction} on your post`,
    linkType: "post",
    linkId: data.postId as any,
  });

  return reaction;
};

const getReactionsByPost = async (postId: string) => {
  return await PostReaction.find({ postId }).populate({
    path: 'userId',
    select: 'username',
    populate: {
      path: 'userDetails',
      select: 'name photo'
    }
  });
};

const getReactionsByUser = async (userId: string) => {
  return await PostReaction.find({ userId }).populate("postId", "title videoUrl");
};

const deleteReaction = async (reactionId: string, userId: string) => {
  const reaction = await PostReaction.findOne({ _id: reactionId, userId });
  if (!reaction) throw new Error("Reaction not found or unauthorized");
  await reaction.deleteOne();
  return true;
};

const getTotalReactionsOfAUser = async (userId: string) => {

  const posts = await Post.find({ authorId: userId }).select("_id").lean();

  const postIds = posts.map(p => p._id);
  if (!postIds.length) return { totalReactions: 0 };

  const totalReactions = await PostReaction.countDocuments({
    postId: { $in: postIds }
  });

  return { totalReactions };
};


export const PostReactionServices = {
  reactToPost,
  getReactionsByPost,
  getReactionsByUser,
  deleteReaction,
  getTotalReactionsOfAUser
};