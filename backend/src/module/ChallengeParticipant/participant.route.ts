import { Router } from "express";
import auth from "../../app/middleware/auth";
import { USER_ROLE } from "../User/user.constant";
import { ChallengeParticipantController } from "./participant.controller";

const router = Router();


router.post("/", auth(USER_ROLE.user, USER_ROLE.admin), ChallengeParticipantController.addParticipant);

router.get("/challenge/:challengeId", ChallengeParticipantController.getParticipantsByChallenge);

router.get("/user/:userId", ChallengeParticipantController.getChallengesByUser);

// Get Ranked Participants by Challenge id
router.get("/all/:challengeId", auth(USER_ROLE.user), ChallengeParticipantController.getAllParticipantsRanked);

// Get Ranked Participants that I created
router.get("/my/challenges", auth(USER_ROLE.user), ChallengeParticipantController.getMyRankedParticipants);

router.delete("/:id", auth(USER_ROLE.user, USER_ROLE.admin), ChallengeParticipantController.removeParticipant);

export const ChallengeParticipantRoutes = router;
