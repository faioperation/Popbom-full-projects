import mongoose from "mongoose";
import { IChallenge, IChallengeResponse, IPopulatedParticipant } from "./challenge.interface";
import { Challenge } from "./challenge.model";
import { ChallengeRule } from "../ChallengeRules/challengeRules.model";
import { ChallengeParticipant } from "../ChallengeParticipant/participant.model";
import { NotificationService } from "../Notification/notification.service";
import { Follow } from "../Follow/follow.model";
import { Post } from "../Post/post.model";
import { PostReaction } from "../PostReaction/reaction.model";
import { PostWatchCount } from "../PostWatchCount/watchCount.model";
import { Comment } from "../Comment/comment.model";
import { SharedPost } from "../SharedPost/sharedPost.model";
import { SavedPost } from "../SavePost/savedPost.model";


const attachChallengeRules = async (challenges: any[]) => {
  // Convert challenge _id to string[]
  const challengeIds = challenges.map(c => c._id.toString());

  // Fetch rules
  const rules = await ChallengeRule.find({
    challengeId: { $in: challengeIds }
  }).lean();

  // FIX: Create a properly typed map
  const rulesMap: Record<string, string[]> = {};

  rules.forEach(r => {
    const cid = r.challengeId.toString();  // Convert ObjectId → string

    if (!rulesMap[cid]) rulesMap[cid] = [];
    rulesMap[cid].push(r.rule);
  });

  // Attach rules back to each challenge
  return challenges.map(c => ({
    ...c,
    rules: rulesMap[c._id.toString()] || []
  }));
};



const getParticipantsInfo = async (challengeIds: string[]) => {
  const participants = await ChallengeParticipant.find({
    challengeId: { $in: challengeIds },
  })
    .populate({
      path: 'participantId',
      select: '_id username',
      populate: {
        path: 'userDetails',
        select: 'name photo',
      },
    })
    .lean<IPopulatedParticipant[]>();

  // Group participants by challengeId
  const grouped = participants.reduce((acc, participant) => {
    const key = participant.challengeId.toString();
    if (!acc[key]) acc[key] = [];

    // check if participant already exists
    if (!acc[key].some(p => p._id === participant.participantId._id)) {
      acc[key].push({
        _id: participant.participantId._id,
        username: participant.participantId.username,
        name: participant.participantId.userDetails?.name || '',
        photo: participant.participantId.userDetails?.photo || '',
      });
    }

    return acc;
  }, {} as Record<string, Array<{ _id: string; username: string; name: string; photo: string }>>);

  return grouped;
};


// // 🧩 Helper: attach participant counts to each challenge
const addParticipantCounts = async (challenges: any[]): Promise<IChallengeResponse[]> => {
  const challengeIds = challenges.map((c) => c._id);
  const participantsMap = await getParticipantsInfo(challengeIds);

  const counts = await ChallengeParticipant.aggregate([
    { $match: { challengeId: { $in: challengeIds } } },
    { $group: { _id: "$challengeId", totalParticipants: { $sum: 1 } } },
  ]);

  const countMap = new Map(
    counts.map((item) => [item._id.toString(), item.totalParticipants])
  );

  return challenges.map((c) => ({
    _id: c._id,
    challengeName: c.challengeName,
    challengeDesc: c.challengeDesc,
    challengePoster: c.challengePoster || "",
    challengeStartDate: c.challengeStartDate,
    challengeEndDate: c.challengeEndDate,
    totalParticipants: countMap.get(c._id.toString()) || 0,
    participants: participantsMap[c._id.toString()] || [],
    rules: c.rules || [],
    author: c.authorId
      ? {
        _id: c.authorId._id,
        username: c.authorId.username,
        photo: c.authorId.userDetails?.photo || "",
        name: c.authorId.userDetails?.name || ""
      }
      : null,
  })) as IChallengeResponse[];
};


const createChallenge = async (
  data: Partial<IChallenge & { rules?: string[] }>
) => {


  try {
    // 1️⃣ Create Challenge
    const challengeDocs = await Challenge.create(
      [
        {
          authorId: data.authorId,
          challengeName: data.challengeName,
          challengeDesc: data.challengeDesc,
          challengePoster: data.challengePoster,
          challengeStartDate: data.challengeStartDate,
          challengeEndDate: data.challengeEndDate,
        },
      ],

    );

    const challenge = challengeDocs[0];

    // 2️⃣ Insert Rules
    if (data.rules && data.rules.length > 0) {
      const ruleDocs = data.rules.map((rule) => ({
        challengeId: challenge._id,
        rule,
      }));

      await ChallengeRule.insertMany(ruleDocs);
    }



    // 2.5️⃣ Notify followers about new challenge
    const followers = await Follow.find({ followedUserId: data.authorId, status: 'follow' });
    for (const follower of followers) {
      await NotificationService.sendNotification({
        userId: follower.followingUserId as any,
        senderId: data.authorId as any,
        type: 'challenge',
        message: `created a new challenge: ${data.challengeName}`,
        linkType: 'challenge',
        linkId: challenge._id as any,
      });
    }

    // 3️⃣ Fetch rules only (NO AUTHOR POPULATE)
    const rules = await ChallengeRule.find({
      challengeId: challenge._id,
    })
      .select("rule -_id")
      .lean();

    // 4️⃣ Return clean response (authorId stays ObjectId string)
    return {
      ...challenge.toObject(),
      challengeRules: rules.map((r) => r.rule),
      totalParticipants: 0,
      participants: [],
    };
  } catch (error) {
    throw error;
  }
};

const getAllChallenges = async (currentUserId: string): Promise<IChallengeResponse[]> => {
  let challenges: any[] = await Challenge.find({
    authorId: { $ne: currentUserId }
  })
    .populate({
      path: 'authorId',
      select: '_id username',
      populate: {
        path: 'userDetails',
        select: 'photo name',
      }
    }).lean();

  challenges = await addParticipantCounts(challenges);
  challenges = await attachChallengeRules(challenges);

  return challenges as unknown as IChallengeResponse[];
};

//  2. Get MY Challenges (the ones I created)
const getMyChallenges = async (userId: string) => {
  const challenges = await Challenge.find({
    authorId: new mongoose.Types.ObjectId(userId),
  })
    .populate({
      path: 'authorId',
      select: '_id username',
      populate: {
        path: 'userDetails',
        select: 'name photo'
      }
    })
    .sort({ createdAt: -1 })
    .lean();

  return await addParticipantCounts(challenges);
};

//3. Get Challenges where I am a PARTICIPANT
const getParticipantChallenges = async (userId: string) => {
  const participantDocs = await ChallengeParticipant.find({
    participantId: new mongoose.Types.ObjectId(userId),
  })
    .populate({
      path: "challengeId",
      populate: {
        path: "authorId",
        select: "_id username",
        populate: { path: 'userDetails', select: 'name photo' }
      },
    })
    .sort({ createdAt: -1 }).lean<IPopulatedParticipant[]>();

  const challenges = participantDocs
    .map((p) => p.challengeId)
    .filter((c) => c !== null)
    .filter((c, i, arr) => arr.findIndex(ch => ch._id.toString() === c._id.toString()) === i);


  return await addParticipantCounts(challenges);
};

const getChallengeById = async (challengeId: string) => {
  const challenge = await Challenge.findById(challengeId)
    .populate({
      path: "authorId",
      select: "_id username",
      populate: {
        path: "userDetails",
        select: "name photo",
      },
    })
    .lean();

  if (!challenge) {
    throw new Error("Challenge not found");
  }
  const rules = await ChallengeRule.find({ challengeId }).select("rule -_id").lean();
  challenge.rules = rules.map(r => r.rule);


  // add participants, participant count, etc.
  const finalChallenge = await addParticipantCounts([challenge]);

  return finalChallenge[0]; // return single object
};


const updateChallenge = async (id: string, data: Partial<IChallenge>) => {
  const res = await Challenge.findByIdAndUpdate(id, data, { new: true, runValidators: true });
  return res;
};

const deleteChallenge = async (id: string) => {
  const res = await Challenge.findByIdAndDelete(id);
  return res;
};

const getAllVideoChallenges = async () => {

  const videos = await Post.find({
    postType: 'challenges'
  }).populate({
    path: 'authorId',
    select: '_id username',
    populate: {
      path: 'userDetails',
      select: 'name photo'
    }
  }).populate({
    path: 'challengeId',
    select: 'challengeName challengePoster',
  }).lean();

  if (videos.length === 0) {
    return videos;
  }

  // Get all postIds
  const postIds = videos.map((v: any) => v._id);

  // Get counts for like, comment, share, saved, and watchCount
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

  // Attach counts to each video
  return videos.map((video: any) => {
    const postIdStr = video._id.toString();

    return {
      ...video,
      counts: {
        like: likeMap.get(postIdStr) || 0,
        comment: commentMap.get(postIdStr) || 0,
        share: shareMap.get(postIdStr) || 0,
        saved: savedMap.get(postIdStr) || 0,
        watchCount: watchCountMap.get(postIdStr) || 0
      }
    };
  });
};


export const ChallengeServices = {
  createChallenge,
  getAllChallenges,
  getMyChallenges,
  getParticipantChallenges,
  updateChallenge,
  deleteChallenge,
  getChallengeById,
  getAllVideoChallenges,
}