import { SavedPost } from "./savedPost.model";
import { Types } from "mongoose";
import mongoose from "mongoose";
import AppError from "../../app/errors/AppError";
import status from "http-status";
import { JwtPayload } from "jsonwebtoken";
import { Post } from "../Post/post.model";
import { PostReaction } from "../PostReaction/reaction.model";
import { PostWatchCount } from "../PostWatchCount/watchCount.model";
import { Comment } from "../Comment/comment.model";
import { SharedPost } from "../SharedPost/sharedPost.model";


interface SavePayload {
  postId: Types.ObjectId | string;
  userId: Types.ObjectId | string;
}

const savePost = async (payload: SavePayload) => {
  try {
    const authorId = await Post.findById(payload.postId).select("authorId");
    if (!authorId) throw new AppError(status.NOT_FOUND, "Post not found");
    if (authorId?.authorId.toString() === payload.userId.toString()) {
      throw new AppError(status.BAD_REQUEST, "You cannot save your own post");
    }

    // check if the post is already saved with the same user
    const isSaved = await SavedPost.findOne({ postId: payload.postId, userId: payload.userId });
    if (isSaved) {
      throw new AppError(status.BAD_REQUEST, "Post already saved");
    }

    const record = await SavedPost.create({
      postId: payload.postId,
      authorId: authorId?.authorId,
      userId: payload.userId,
    });

    return record;
  } catch (err: any) {
    // handle duplicate key (already saved)
    if (err?.code === 11000) {
      throw new AppError(status.CONFLICT, "Post already saved");
    }
    throw err;
  }
};


const getSavedById = async (id: string) => {
  const record = await SavedPost.findById(id).populate("postId", "title videoUrl")
    .populate({
      path: "userId",
      select: "username",
      populate: {
        path: "userDetails",
        select: "name photo"
      }
    });

  if (!record) throw new AppError(status.NOT_FOUND, "Saved post not found");
  return record;
};

const getSavedByUser = async (userId: string) => {
  // Query 1: Get all saved posts with post and author data
  const savedPosts = await SavedPost.aggregate([
    // Step 1: Get all SavedPost documents for this userId
    {
      $match: {
        userId: new mongoose.Types.ObjectId(userId)
      }
    },

    // Step 2: Join Post data using SavedPost.postId
    {
      $lookup: {
        from: "posts",
        localField: "postId",
        foreignField: "_id",
        as: "post"
      }
    },
    { $unwind: "$post" },

    // Step 3: Join author User data using SavedPost.authorId
    {
      $lookup: {
        from: "users",
        localField: "authorId",
        foreignField: "_id",
        as: "author"
      }
    },
    { $unwind: "$author" },

    // Step 4: Join author UserDetails
    {
      $lookup: {
        from: "userdetails",
        localField: "author._id",
        foreignField: "userId",
        as: "authorDetails"
      }
    },
    { $unwind: { path: "$authorDetails", preserveNullAndEmptyArrays: true } },

    // Step 5: Sort by createdAt descending
    { $sort: { createdAt: -1 } },

    // Step 6: Project basic fields
    {
      $project: {
        _id: 1,
        postId: "$post._id",
        post: {
          title: "$post.title",
          videoUrl: "$post.videoUrl",
          createdAt: "$post.createdAt"
        },
        authorId: "$author._id",
        author: {
          username: "$author.username"
        },
        authorDetails: {
          name: "$authorDetails.name",
          photo: "$authorDetails.photo"
        },
        createdAt: 1,
        updatedAt: 1
      }
    }
  ]);

  // Query 2: Get all postIds
  const postIds = savedPosts.map((sp: any) => sp.postId);

  if (postIds.length === 0) {
    return [];
  }

  // Query 3: Get counts for like, comment, share, saved, and watchCount
  const [likeCounts, commentCounts, shareCounts, savedCounts, watchCounts] = await Promise.all([
    // Like count (PostReaction where reaction = "like")
    PostReaction.aggregate([
      {
        $match: {
          postId: { $in: postIds },
          reaction: "like"
        }
      },
      {
        $group: {
          _id: "$postId",
          count: { $sum: 1 }
        }
      }
    ]),
    // Comment count
    Comment.aggregate([
      {
        $match: {
          postId: { $in: postIds }
        }
      },
      {
        $group: {
          _id: "$postId",
          count: { $sum: 1 }
        }
      }
    ]),
    // Share count
    SharedPost.aggregate([
      {
        $match: {
          postId: { $in: postIds }
        }
      },
      {
        $group: {
          _id: "$postId",
          count: { $sum: 1 }
        }
      }
    ]),
    // Saved count (how many users saved this post)
    SavedPost.aggregate([
      {
        $match: {
          postId: { $in: postIds }
        }
      },
      {
        $group: {
          _id: "$postId",
          count: { $sum: 1 }
        }
      }
    ]),
    // Watch counts
    PostWatchCount.find({
      postId: { $in: postIds }
    }).lean()
  ]);

  // Build maps: postId -> count
  const likeMap = new Map<string, number>();
  const commentMap = new Map<string, number>();
  const shareMap = new Map<string, number>();
  const savedMap = new Map<string, number>();
  const watchCountMap = new Map<string, number>();

  // Process like counts
  likeCounts.forEach((item: any) => {
    likeMap.set(item._id.toString(), item.count);
  });

  // Process comment counts
  commentCounts.forEach((item: any) => {
    commentMap.set(item._id.toString(), item.count);
  });

  // Process share counts
  shareCounts.forEach((item: any) => {
    shareMap.set(item._id.toString(), item.count);
  });

  // Process saved counts
  savedCounts.forEach((item: any) => {
    savedMap.set(item._id.toString(), item.count);
  });

  // Process watch counts
  watchCounts.forEach((wc: any) => {
    watchCountMap.set(wc.postId.toString(), wc.watchCount || 0);
  });

  // Transform to match expected structure and attach counts
  return savedPosts.map((item: any) => {
    const postIdStr = item.postId.toString();

    return {
      _id: item._id,
      postId: {
        _id: item.postId,
        title: item.post?.title,
        videoUrl: item.post?.videoUrl,
        createdAt: item.post?.createdAt
      },
      authorId: {
        _id: item.authorId,
        username: item.author?.username,
        userDetails: {
          name: item.authorDetails?.name,
          photo: item.authorDetails?.photo
        }
      },
      counts: {
        like: likeMap.get(postIdStr) || 0,
        comment: commentMap.get(postIdStr) || 0,
        share: shareMap.get(postIdStr) || 0,
        saved: savedMap.get(postIdStr) || 0,
        watchCount: watchCountMap.get(postIdStr) || 0
      },
      createdAt: item.createdAt,
      updatedAt: item.updatedAt
    };
  });
};

const deleteSaved = async (postId: string, user: JwtPayload) => {

  const record = await SavedPost.find({ postId });
  if (!record) throw new AppError(status.NOT_FOUND, "Saved post not found");

  const deleted = await SavedPost.findOneAndDelete({
    _id: postId,
  });

  if (!deleted) {
    throw new AppError(status.NOT_FOUND, "Saved post not found");
  }

  return true;
};

export const SavedPostServices = {
  savePost,
  getSavedById,
  getSavedByUser,
  deleteSaved,
};