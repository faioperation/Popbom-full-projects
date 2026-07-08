import { catchAsync } from "../../app/utils/catchAsync";
import sendResponse from "../../app/utils/sendResponse";
import status from "http-status";
import { ChallengeServices } from "./challenge.service";
import { JwtPayload } from "jsonwebtoken";

const createChallenge = catchAsync(async (req, res) => {
  const fileUrl = req.file?.path;
  const data = {
    ...req.body,
    authorId: req.user?.id,
    challengePoster: fileUrl
  };

  if (typeof data.rules === 'string') {
    try {
      data.rules = JSON.parse(data.rules);
    } catch (error) {
      data.rules = [];
    }
  }
  const challenge = await ChallengeServices.createChallenge(data);

  sendResponse(res, {
    statusCode: status.CREATED,
    success: true,
    message: "Challenge created successfully",
    data: challenge,
  });
});

//Get all challenges
const getAllChallenges = catchAsync(async (req, res) => {

  const currentUserId = req.user?._id;
  
  const result = await ChallengeServices.getAllChallenges(currentUserId);

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: "Challenges retrieved successfully",
    data: result,
  });
});

//Get my created challenges
const getMyChallenges = catchAsync(async (req, res) => {
  const user = req.user as JwtPayload;
  const userId = user._id;

  const result = await ChallengeServices.getMyChallenges(userId);

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: "My challenges retrieved successfully",
    data: result,
  });
});

//Get challenges I participated in
const getParticipantChallenges = catchAsync(async (req, res) => {
  const user = req.user as JwtPayload;
  const userId = user._id;

  const result = await ChallengeServices.getParticipantChallenges(userId);

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: "Participated challenges retrieved successfully",
    data: result,
  });
});

const getChallengeById = catchAsync(async (req, res) => {
  const challengeId = req.params.id;

  const result = await ChallengeServices.getChallengeById(challengeId);

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: "Challenge retrieved successfully",
    data: result,
  });
});


const updateChallenge = catchAsync(async (req, res) => {
  const challenge = await ChallengeServices.updateChallenge(req.params.id, req.body);

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    data: challenge,
  });
});

const deleteChallenge = catchAsync(async (req, res) => {
  await ChallengeServices.deleteChallenge(req.params.id);

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: "Challenge deleted successfully",
    data: null,
  });
});


const getAllVideoChallenges = catchAsync(async (req, res) => {

  const result = await ChallengeServices.getAllVideoChallenges();
  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: "Video challenges retrieved successfully",
    data: result,
  });
});
export const ChallengeController = {
  createChallenge,
  getAllChallenges,
  getMyChallenges,
  getParticipantChallenges,
  getChallengeById,
  updateChallenge,
  deleteChallenge,
  getAllVideoChallenges,
};