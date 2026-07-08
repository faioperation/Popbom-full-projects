import mongoose from "mongoose";
import { Post } from "../Post/post.model";
import { IChallengeParticipant } from "./participant.interface";
import { ChallengeParticipant } from "./participant.model";
import { Challenge } from "../Challenge/challenge.model";
import AppError from "../../app/errors/AppError";
import status from "http-status";



const addParticipant = async (data: Partial<IChallengeParticipant>) => {
  // check if the chellenges is exist
  const challenge = await Challenge.findById(data.challengeId);
  if (!challenge) {
    throw new AppError(status.BAD_REQUEST, "Challenge not found");
  }
  // check if the author is join the challenge
  if (challenge.authorId.toString() === data.participantId?.toString()) {
    throw new AppError(status.BAD_REQUEST, "You are the author of the challenge, you cannot join your own challenge");
  }
  // check if the post is already joined the challenge
  const isJoined = await ChallengeParticipant.findOne({ postId: data.postId, challengeId: data.challengeId });
  if (isJoined) {
    throw new AppError(status.BAD_REQUEST, "You have already joined the challenge");
  }
  const participant = await ChallengeParticipant.create(data);
  return participant;
};

const getParticipantsByChallenge = async (challengeId: string) => {
  return await ChallengeParticipant.find({ challengeId })
    .populate("participantId", "name photo")
    .populate("postId", "title videoUrl");
};

const getChallengesByUser = async (userId: string) => {
  return await ChallengeParticipant.find({ participantId: userId })
    .populate("challengeId", "challengeName challengePoster")
    .populate("postId", "title videoUrl");
};

const removeParticipant = async (id: string) => {
  return await ChallengeParticipant.findByIdAndDelete(id);
};

const getAllParticipantsRanked = async (challengeId: string) => {

  const ranking = await ChallengeParticipant.aggregate([
    {
      $match: {
        challengeId: new mongoose.Types.ObjectId(challengeId)
      }
    },

    // 🔹 Join watch count
    {
      $lookup: {
        from: "postwatchcounts",
        localField: "postId",
        foreignField: "postId",
        as: "watchData"
      }
    },

    {
      $addFields: {
        watchCount: {
          $ifNull: [{ $arrayElemAt: ["$watchData.watchCount", 0] }, 0]
        }
      }
    },

    // 🔹 Sort by highest views
    { $sort: { watchCount: -1 } },

    // 🔹 Join user
    {
      $lookup: {
        from: "users",
        localField: "participantId",
        foreignField: "_id",
        as: "user"
      }
    },
    { $unwind: "$user" },

    // 🔹 Join userDetails for name & photo
    {
      $lookup: {
        from: "userdetails",
        localField: "user._id",
        foreignField: "userId",
        as: "userDetails"
      }
    },
    { $unwind: { path: "$userDetails", preserveNullAndEmptyArrays: true } },

    // 🔹 Final output
    {
      $project: {
        participantId: 1,
        postId: 1,
        watchCount: 1,
        "user.username": 1,
        "userDetails.name": 1,
        "userDetails.photo": 1
      }
    }
  ]);


  return ranking;

};

const getMyRankedParticipants = async (userId: string) => {
  // 🔹 Get all challenges created by the user
  const challenges = await Challenge.find({
    authorId: new mongoose.Types.ObjectId(userId)
  }).lean();

  // 🔹 For each challenge, get ranked participants
  const challengesWithRankings = await Promise.all(
    challenges.map(async (challenge) => {
      // 🔹 Get ranked participants for this challenge
      const participants = await ChallengeParticipant.aggregate([
        {
          $match: {
            challengeId: challenge._id
          }
        },

        // 🔹 Join watch count
        {
          $lookup: {
            from: "postwatchcounts",
            localField: "postId",
            foreignField: "postId",
            as: "watchData"
          }
        },

        {
          $addFields: {
            watchCount: {
              $ifNull: [{ $arrayElemAt: ["$watchData.watchCount", 0] }, 0]
            }
          }
        },

        // 🔹 Sort by highest views
        { $sort: { watchCount: -1 } },

        // 🔹 Join user
        {
          $lookup: {
            from: "users",
            localField: "participantId",
            foreignField: "_id",
            as: "user"
          }
        },
        { $unwind: "$user" },

        // 🔹 Join userDetails for name & photo
        {
          $lookup: {
            from: "userdetails",
            localField: "user._id",
            foreignField: "userId",
            as: "userDetails"
          }
        },
        { $unwind: { path: "$userDetails", preserveNullAndEmptyArrays: true } },

        // 🔹 Project fields
        {
          $project: {
            participantId: 1,
            postId: 1,
            watchCount: 1,
            "user._id": 1,
            "user.username": 1,
            "userDetails.name": 1,
            "userDetails.photo": 1
          }
        }
      ]);

      // 🔹 Add rank to each participant (handles ties)
      let currentRank = 1;
      let previousWatchCount: number | null = null;

      const rankedParticipants = participants.map((participant, index) => {
        // If watch count is different from previous, update rank
        if (previousWatchCount !== null && participant.watchCount !== previousWatchCount) {
          currentRank = index + 1;
        } else if (previousWatchCount === null) {
          currentRank = 1;
        }
        // If same watch count, keep same rank (ties share rank)

        previousWatchCount = participant.watchCount;

        return {
          userId: participant.user._id,
          name: participant.userDetails?.name || "",
          photo: participant.userDetails?.photo || "",
          username: participant.user.username,
          watchCount: participant.watchCount,
          rank: currentRank
        };
      });

      return {
        challengeId: challenge._id,
        challengeName: challenge.challengeName,
        challengeDesc: challenge.challengeDesc,
        challengePoster: challenge.challengePoster,
        challengeStartDate: challenge.challengeStartDate,
        challengeEndDate: challenge.challengeEndDate,
        participants: rankedParticipants
      };
    })
  );

  return challengesWithRankings;
};

export const ChallengeParticipantServices = {
  addParticipant,
  getParticipantsByChallenge,
  getChallengesByUser,
  removeParticipant,
  getAllParticipantsRanked,
  getMyRankedParticipants,
};
