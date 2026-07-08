import { Story } from "./story.model";
import { IStory } from "./story.interface";
import { JwtPayload } from "jsonwebtoken";
import AppError from "../../app/errors/AppError";
import status from "http-status";
import { Follow } from "../Follow/follow.model";
import mongoose from "mongoose";


// Get story by ID
const getStoryById = async (storyId: string) => {
  return Story.findById(storyId).populate("authorId", "name photo").populate("postId");
};

// Get all stories of a user
const getStoriesByUser = async (userId: string) => {
  const now = new Date();

  const rawStories = await Story.find({ 
    authorId: userId,
    expiresAt: { $gt: now },
  })
    .sort({ createdAt: -1 })
    .populate({
      path: "authorId",
      select: "username",
      populate: { path: "userDetails", select: "name photo" },
    })
    .populate({
      path: "postId",
      populate: {
        path: "authorId",
        select: "username",
        populate: { path: "userDetails", select: "name photo" },
      },
    }).lean();

    const formattedStories = rawStories.map((s: any) => ({
    storyId: s._id,

    userId: s.authorId?._id,
    username: s.authorId?.username,
    name: s.authorId?.userDetails?.name,
    photo: s.authorId?.userDetails?.photo,

    videoUrl: s.postId?.videoUrl || null,
    musicUrl: s.postId?.musicUrl || null,
    status: s.postId?.status,
  }));

  return formattedStories;
};

// Get stories for feed (from following)
const getFeed = async (userId:string) => {
  const now = new Date();

  //who i follow
  const followings =  await Follow.find({
    followingUserId:userId,
    status:"follow"
  }).select("followedUserId");

  // who follow me
  const followers = await Follow.find({
    followedUserId:userId,
    status:"follow"
  }).select("followingUserId");

  const followingIds = followings.map(f => f.followedUserId);
  const followerIds = followers.map(f => f.followingUserId);

   const userList = [
    ...new Set([
      ...followingIds,
      ...followerIds,
      new mongoose.Types.ObjectId(userId)
    ])
  ];

    const stories = await Story.find({
    authorId: { $in: userList },
    expiresAt: { $gt: now }
  })
    .sort({ createdAt: -1 })
    .populate({
      path: "authorId",
      select: "username",
      populate: { path: "userDetails", select: "name photo" }
    })
    .populate({
      path: "postId",
      populate: {
        path: "authorId",
        select: "username",
        populate: { path: "userDetails", select: "name photo" }
      }
    })
    .lean();
    
     const formattedStories = stories.map((s: any) => ({
      storyId: s._id,
      userId: s.authorId?._id,
      username: s.authorId?.username,
      name: s.authorId?.userDetails?.name,
      photo: s.authorId?.userDetails?.photo,
      videoUrl: s.postId?.videoUrl || null,
      musicUrl: s.postId?.musicUrl || null,
      status: s.postId?.status,
}));


    return formattedStories;
};

// Delete story (author or admin)
const deleteStory = async (storyId: string, user: JwtPayload) => {
  const story = await Story.findById(storyId);
  if (!story) throw new AppError(status.NOT_FOUND, "Story not found");

  if (story.authorId.toString() !== user.id && user.role !== "admin") {
    throw new AppError(status.UNAUTHORIZED, "You are not authorized to delete this story");
  }

  await Story.findByIdAndDelete(storyId);
};

export const StoryServices = {
  // createStory,
  getStoryById,
  getStoriesByUser,
  getFeed,
  deleteStory,
};

//story related service golo post model teke korte hba
