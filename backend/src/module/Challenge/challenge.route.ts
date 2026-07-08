import { Router } from "express";
import { ChallengeController } from "./challenge.controller";
import auth from "../../app/middleware/auth";
import { USER_ROLE } from "../User/user.constant";
import upload from "../../app/middleware/upload";

const router = Router();

router.post("/", 
    auth(USER_ROLE.user, USER_ROLE.admin),
    upload.single("challengePoster"), 
    ChallengeController.createChallenge);

router.get("/all", auth(USER_ROLE.user) ,ChallengeController.getAllChallenges);
router.get("/my", auth(USER_ROLE.user), ChallengeController.getMyChallenges);
router.get("/participated", auth(USER_ROLE.user), ChallengeController.getParticipantChallenges);
router.get("/videos", ChallengeController.getAllVideoChallenges);
router.get(
  "/:id",
  auth(USER_ROLE.user, USER_ROLE.admin),
  ChallengeController.getChallengeById
);



router.patch("/:id", auth(USER_ROLE.user, USER_ROLE.admin), ChallengeController.updateChallenge);

router.delete("/:id", auth(USER_ROLE.user, USER_ROLE.admin), ChallengeController.deleteChallenge);








export const ChallengeRoutes = router;
