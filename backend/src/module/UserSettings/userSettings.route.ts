import { Router } from "express";
import { UserSettingsController } from "./userSettings.controller";
import auth from "../../app/middleware/auth";
import { USER_ROLE } from "../User/user.constant";
import validateRequest from "../../app/middleware/validateRequest";
import { UserSettingsValidation } from "./userSettings.validation";


const router = Router();

router.post(
  '/:userId',
  auth(USER_ROLE.user, USER_ROLE.admin),
  validateRequest(UserSettingsValidation.createOrUpdateSchema),
  UserSettingsController.createOrUpdate
);

router.get(
  '/:userId',
  auth(USER_ROLE.user, USER_ROLE.admin),
  UserSettingsController.getSettings
);

export const UserSettingsRoutes = router;
