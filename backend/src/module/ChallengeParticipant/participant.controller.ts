import { catchAsync } from "../../app/utils/catchAsync";
import sendResponse from "../../app/utils/sendResponse";
import status from "http-status";
import { ChallengeParticipantServices } from "./participant.service";
import AppError from "../../app/errors/AppError";
import { JwtPayload } from "jsonwebtoken";

const addParticipant = catchAsync(async (req, res) => {
  const data = { ...req.body, participantId: req.user?.id };
 
  const participant = await ChallengeParticipantServices.addParticipant(data);

  sendResponse(res, {
    statusCode: status.CREATED,
    success: true,
    message: "Participant added successfully",
    data: participant,
  });
});

const getParticipantsByChallenge = catchAsync(async (req, res) => {
  const { challengeId } = req.params;
  const participants = await ChallengeParticipantServices.getParticipantsByChallenge(challengeId);

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    data: participants,
  });
});

const getChallengesByUser = catchAsync(async (req, res) => {
  const { userId } = req.params;
  const challenges = await ChallengeParticipantServices.getChallengesByUser(userId);

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    data: challenges,
  });
});

const removeParticipant = catchAsync(async (req, res) => {
  await ChallengeParticipantServices.removeParticipant(req.params.id);

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: "Participant removed successfully",
    data: null,
  });
});

const getAllParticipantsRanked = catchAsync(async (req, res) => {
  const { challengeId } = req.params;
  if (!challengeId) throw new AppError(status.BAD_REQUEST, "Challenge ID is required");
  const ranking = await ChallengeParticipantServices.getAllParticipantsRanked(challengeId);

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    data: ranking,
  });
});

const getMyRankedParticipants = catchAsync(async (req, res) => {
  const user = req.user as JwtPayload;
  const userId = user._id;
  const ranking = await ChallengeParticipantServices.getMyRankedParticipants(userId);
  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    data: ranking,
  });
});

export const ChallengeParticipantController = {
  addParticipant,
  getParticipantsByChallenge,
  getChallengesByUser,
  removeParticipant,
  getAllParticipantsRanked,
  getMyRankedParticipants,
};
