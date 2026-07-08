
import { Types } from "mongoose";
import AppError from "../../app/errors/AppError";
import status from "http-status";
import { IPostWatchCount } from "./watchCount.interface";
import { PostWatchCount } from "./watchCount.model";

/**
 * Increment watch count atomically.
 * amount defaults to 1 (one view).
 * Returns the updated record.
 */
const incrementWatchCount = async (
  postId: Types.ObjectId | string,
  amount = 1
): Promise<IPostWatchCount | null> => {
  const updated = await PostWatchCount.findOneAndUpdate(
    { postId },
    { $inc: { watchCount: amount } },
    { new: true, upsert: true, setDefaultsOnInsert: true }
  );
  return updated;
};

/**
 * Get watch count by postId.
 */
const getWatchCountByPost = async (postId: string) => {
  const rec = await PostWatchCount.findOne({ postId }).lean();
  return rec || { postId, watchCount: 0 };
};

/**
 * Set watch count explicitly (admin operation).
 */
const setWatchCount = async (postId: string, count: number) => {
  if (count < 0) throw new AppError(status.BAD_REQUEST, "Count cannot be negative");
  const rec = await PostWatchCount.findOneAndUpdate(
    { postId },
    { watchCount: count },
    { new: true, upsert: true, setDefaultsOnInsert: true }
  );
  return rec;
};

/**
 * Reset count (set to zero).
 */
const resetWatchCount = async (postId: string) => {
  const rec = await PostWatchCount.findOneAndUpdate(
    { postId },
    { watchCount: 0 },
    { new: true }
  );
  return rec;
};

/**
 * Optional: rebuild counts from PostWatch collection.
 * This is useful if you keep per-user watch records and want to recompute totals.
 * This function assumes you have a PostWatch model with { postId, count }.
 */
const rebuildCountsFromPostWatch = async (PostWatchModel: any) => {
  // Aggregate sums by postId from PostWatch collection
  const agg = await PostWatchModel.aggregate([
    { $group: { _id: "$postId", total: { $sum: "$count" } } }
  ]);

  const ops = agg.map((row: any) => ({
    updateOne: {
      filter: { postId: row._id },
      update: { $set: { watchCount: row.total } },
      upsert: true,
    },
  }));

  if (ops.length > 0) {
    await PostWatchCount.bulkWrite(ops);
  }

  return { rebuilt: ops.length };
};

export const PostWatchCountServices = {
  incrementWatchCount,
  getWatchCountByPost,
  setWatchCount,
  resetWatchCount,
  rebuildCountsFromPostWatch,
};
