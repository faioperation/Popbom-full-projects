import { Router } from "express";
import { GiftController } from "./gift.controller";
import auth from "../../app/middleware/auth";
import { USER_ROLE } from "../User/user.constant";
import validateRequest from "../../app/middleware/validateRequest";
import { GiftValidation } from "./gift.validation";


const router = Router();

router.post(
  '/',
  auth(USER_ROLE.user, USER_ROLE.admin),
  validateRequest(GiftValidation.sendGiftSchema),
  GiftController.sendGift
);

export const GiftRoutes = router;
