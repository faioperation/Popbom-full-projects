
import mongoose, { Types } from "mongoose";
import AppError from "../../app/errors/AppError";
import status from "http-status";
import { JwtPayload } from "jsonwebtoken";
import { PostWatch } from "./watch.model";
import { PostWatchCount } from "../PostWatchCount/watchCount.model";


const recordWatch = async (
  userId: Types.ObjectId | string,
  postId: Types.ObjectId | string
) => {

  try {

    const existing = await PostWatch.findOne({ userId, postId });

    if (!existing) {
      // first-time viewer -> create PostWatch and increment PostWatchCount
      await PostWatch.create(
        [{ userId, postId, count: 1 }],

      );

      const updatedCount = await PostWatchCount.findOneAndUpdate(
        { postId },
        { $inc: { watchCount: 1 } },
        { upsert: true, new: true, setDefaultsOnInsert: true }
      );



      // populate as needed
      const created = await PostWatch.findOne({ userId, postId });
      return { firstTime: true, postWatch: created, postWatchCount: updatedCount };
    } else {
      // already viewed -> increment personal count only
      const updated = await PostWatch.findOneAndUpdate(
        { userId, postId },
        { $inc: { count: 1 } },
        { new: true }
      );


      return { firstTime: false, postWatch: updated, postWatchCount: null };
    }
  } catch (err) {

    throw err;
  }
};

const getWatchesByUser = async (userId: string) => {
  const data = await PostWatch.find({ userId })
    .sort({ updatedAt: -1 })
    .populate("postId", "title videoUrl createdAt")
    .populate("userId", "name photo");

  return data;
};

const getWatchesByPost = async (postId: string) => {
  const data = await
    PostWatch.find({ postId })
      .sort({ updatedAt: -1 })
      .populate("userId", "name photo")
      .populate("postId", "title videoUrl");

  return data;
};

const getWatchById = async (id: string) => {
  const rec = await PostWatch.findById(id)
    .populate("postId", "title videoUrl")
    .populate("userId", "name photo");
  if (!rec) throw new AppError(status.NOT_FOUND, "Watch record not found");
  return rec;
};

const deleteWatch = async (id: string, user: JwtPayload) => {
  const rec = await PostWatch.findById(id);
  if (!rec) throw new AppError(status.NOT_FOUND, "Watch record not found");

  // Only owner or admin can delete
  if (rec.userId.toString() !== (user.id as string) && user.role !== "admin") {
    throw new AppError(status.UNAUTHORIZED, "You are not authorized to delete this watch record");
  }

  await PostWatch.findByIdAndDelete(id);
  return true;
};

export const PostWatchServices = {
  recordWatch,
  getWatchesByUser,
  getWatchesByPost,
  getWatchById,
  deleteWatch,
};
