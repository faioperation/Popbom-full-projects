import { Router } from "express";
import { AiRecommendationController } from "./aiRecommendation.controller";
import auth from "../../app/middleware/auth";
import { USER_ROLE } from "../User/user.constant";

const router = Router();

router.get("/get-feed", auth(USER_ROLE.user), AiRecommendationController.getFeedForUser);

router.get("/get-stem-feed", auth(USER_ROLE.user), AiRecommendationController.getStemFeed);

export const AiRecommendationRoutes = router;