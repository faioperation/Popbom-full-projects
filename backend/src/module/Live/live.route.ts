import { Router } from "express";
import { LiveController } from "./live.controller";
import auth from "../../app/middleware/auth";
import { USER_ROLE } from "../User/user.constant";
import validateRequest from "../../app/middleware/validateRequest";
import { LiveValidation } from "./live.validation";

const router = Router();

// 1. Generate Agora Token (CRITICAL)
router.post(
    "/agora/token",
    auth(USER_ROLE.user, USER_ROLE.admin),
    validateRequest(LiveValidation.generateTokenSchema),
    LiveController.generateToken
);

// 2. Start Live
router.post(
    "/start",
    auth(USER_ROLE.user, USER_ROLE.admin),
    validateRequest(LiveValidation.startLiveSchema),
    LiveController.startLive
);

// 3. End Live
router.post(
    "/end",
    auth(USER_ROLE.user, USER_ROLE.admin),
    LiveController.endLive
);

// 4. Get Active Lives (Public - for audience)
router.get("/active", LiveController.getActiveLives);

// 5. Get My Live (for broadcaster) - MUST come before /:liveId route
router.get(
    "/my-live",
    auth(USER_ROLE.user, USER_ROLE.admin),
    LiveController.getMyLive
);

// 6. Get Live by ID - MUST come after all specific routes
router.get("/:liveId", LiveController.getLiveById);

// 7. Viewer Join
router.post(
    "/viewer/join",
    auth(USER_ROLE.user, USER_ROLE.admin),
    validateRequest(LiveValidation.viewerJoinLeaveSchema),
    LiveController.viewerJoin
);

// 8. Viewer Leave
router.post(
    "/viewer/leave",
    auth(USER_ROLE.user, USER_ROLE.admin),
    validateRequest(LiveValidation.viewerJoinLeaveSchema),
    LiveController.viewerLeave
);

export const LiveRoutes = router;
