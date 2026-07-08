import { Router } from "express";
import auth from "../../app/middleware/auth";
import { USER_ROLE } from "../User/user.constant";
import { ShareProfileControllers } from "./shareProfile.controller";

const router = Router();

router.get(
    "/",
    auth(USER_ROLE.user, USER_ROLE.admin),
    ShareProfileControllers.getShareProfileData
);

router.get(
    "/:username",
    auth(USER_ROLE.user, USER_ROLE.admin),
    ShareProfileControllers.getShareProfileDataByUsername
);

export const ShareProfileRoutes = router;
