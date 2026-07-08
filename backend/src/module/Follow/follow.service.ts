import { Follow } from './follow.model';
import AppError from '../../app/errors/AppError';
import status from 'http-status';
import { JwtPayload } from 'jsonwebtoken';
import { NotificationService } from '../Notification/notification.service';


const toggleFollow = async (followingUserId: string, followedUserId: string) => {
  if (followingUserId === followedUserId) {
    throw new AppError(status.BAD_REQUEST, "You can't follow yourself");
  }

  const existing = await Follow.findOne({ followingUserId, followedUserId });
  if (existing) {
    existing.status = existing.status === "follow" ? "unfollow" : "follow";
    await existing.save();

    if (existing.status === 'follow') {
      await NotificationService.sendNotification({
        userId: followedUserId,
        senderId: followingUserId,
        type: 'follow',
        message: 'started following you',
        linkType: 'profile',
        linkId: followingUserId,
      });
    }

    return {
      followed: existing.status === 'follow',
      record: {
        followingUserId,
        followedUserId,
        status: existing.status
      }
    };
  }

  const record = await Follow.create({
    followingUserId,
    followedUserId,
    status: 'follow'
  });

  await NotificationService.sendNotification({
    userId: followedUserId,
    senderId: followingUserId,
    type: 'follow',
    message: 'started following you',
    linkType: 'profile',
    linkId: followingUserId,
  });

  return {
    followed: true,
    record: {
      followingUserId,
      followedUserId,
      status: 'follow',
    }
  };
};

const isFollowing = async (followerId: string, targetId: string) => {
  const rec = await Follow.findOne({
    followingUserId: followerId,
    followedUserId: targetId,
    status: "follow"
  });
  return !!rec;
};

const getFollowers = async (userId: string) => {
  const result = await Follow.find({
    followedUserId: userId,
    status: "follow"
  })
    .sort({ createdAt: -1 })
    .populate({
      path: 'followingUserId',
      select: 'username email',
      populate: {
        path: 'userDetails',
        select: 'name photo'
      }
    })


  return result;
};

const getFollowing = async (userId: string) => {
  const result = await Follow.find({
    followingUserId: userId,
    status: "follow"
  })
    .sort({ createdAt: -1 })
    .populate({
      path: 'followedUserId',
      select: 'username email',
      populate: {
        path: 'userDetails',
        select: 'name photo'
      }
    });


  return result;
};

const unfollowById = async (id: string, user: JwtPayload) => {
  const record = await Follow.findById(id);
  if (!record) throw new AppError(status.NOT_FOUND, 'Follow record not found');

  // Only the follower or admin can delete
  const followerId = record.followingUserId.toString();
  if (followerId !== (user.id as string) && user.role !== 'admin') {
    throw new AppError(status.UNAUTHORIZED, 'You are not authorized to remove this follow');
  }

  await Follow.findByIdAndDelete(id);
  return true;
};

export const FollowServices = {
  toggleFollow,
  isFollowing,
  getFollowers,
  getFollowing,
  unfollowById,
};
