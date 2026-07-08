import { Types } from "mongoose";
import { Post } from "../Post/post.model";
import { Notification } from "./notification.model";
import { INotificationPayload } from "./notification.interface";
import { PostReaction } from "../PostReaction/reaction.model";



const sendNotification = async (payload: INotificationPayload) => {

  if (payload.userId.toString() === payload.senderId.toString()) return;

  const notification = await Notification.create({
    ...payload,
    isRead: false,
  });

  return notification;
};


const createReactionNotification = async (data: { postId: string, userId: string, reaction: string }) => {
  const post = await Post.findById(data.postId);
  if (!post) throw new Error("Post not found");

  return await sendNotification({
    userId: post.authorId.toString(),
    senderId: data.userId,
    type: "reaction",
    message: `reacted with ${data.reaction} on your post`,
    linkType: "post",
    linkId: data.postId,
  });
};

const createCommentNotification = async (data: { postId: string, userId: string }) => {
  const post = await Post.findById(data.postId);
  if (!post) throw new Error("Post not found");

  return await sendNotification({
    userId: post.authorId.toString(),
    senderId: data.userId,
    type: "comment",
    message: `commented on your post`,
    linkType: "post",
    linkId: data.postId,
  });
};

const getNotificationsForUser = async (userId: string) => {
  // Get all notifications
  const allNotifications = await Notification.find({ userId })
    .sort({ createdAt: -1 })
    .populate({
      path: "senderId",
      select: "username",
      populate: { path: "userDetails", select: "name photo" }
    })
    .lean();

  // Separate reaction notifications from others
  const reactionNotifications: any[] = [];
  const otherNotifications: any[] = [];

  allNotifications.forEach((notification: any) => {
    if (notification.type === "reaction") {
      reactionNotifications.push(notification);
    } else {
      otherNotifications.push(notification);
    }
  });

  // Group reaction notifications by postId (linkId)
  const reactionGroups = new Map<string, any[]>();

  reactionNotifications.forEach((notification: any) => {
    const postId = notification.linkId?.toString();
    if (postId) {
      if (!reactionGroups.has(postId)) {
        reactionGroups.set(postId, []);
      }
      reactionGroups.get(postId)!.push(notification);
    }
  });

  // Process each group: get latest notification and total count
  const groupedReactionNotifications: any[] = [];

  for (const [postId, notifications] of reactionGroups.entries()) {
    // Sort by createdAt descending to get latest first
    const sortedNotifications = notifications.sort((a: any, b: any) =>
      new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime()
    );

    const latestNotification = sortedNotifications[0];

    // Get total reaction count for this post from PostReaction collection
    const totalPostReactions = await PostReaction.countDocuments({
      postId: new Types.ObjectId(postId)
    });

    // Get latest sender's username
    const latestSender = latestNotification.senderId;
    const latestUsername = latestSender?.username || latestSender?.userDetails?.name || "Someone";

    // Create combined message: "{username} and {total-1} others reacted to your post"
    const othersCount = totalPostReactions - 1;
    let message: string;

    if (othersCount > 0) {
      message = `${latestUsername} and ${othersCount} others reacted to your post`;
    } else {
      message = `${latestUsername} reacted to your post`;
    }

    // Create a combined notification object
    groupedReactionNotifications.push({
      _id: latestNotification._id,
      userId: latestNotification.userId,
      senderId: latestNotification.senderId,
      type: "reaction",
      message: message,
      linkType: latestNotification.linkType,
      linkId: latestNotification.linkId,
      isRead: latestNotification.isRead,
      createdAt: latestNotification.createdAt,
      totalReactions: totalPostReactions
    });
  }

  // Combine and sort all notifications by createdAt
  const finalNotifications = [...otherNotifications, ...groupedReactionNotifications].sort(
    (a: any, b: any) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime()
  );

  return finalNotifications;
};

const markAsRead = async (id: string) => {
  return await Notification.findByIdAndUpdate(id, { isRead: true }, { new: true });
};

export const NotificationService = {
  sendNotification,
  createReactionNotification,
  createCommentNotification,
  getNotificationsForUser,
  markAsRead,
};
