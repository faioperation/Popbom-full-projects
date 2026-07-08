import { Router } from "express";
import auth from "../../app/middleware/auth";
import { USER_ROLE } from "../User/user.constant";
import { MusicController } from "./music.controller";


const router = Router();

router.get(
    "/search",
    auth(USER_ROLE.admin, USER_ROLE.user),
    MusicController.searchMusic
);

// router.get(
//     "/trending",
//     auth(USER_ROLE.admin, USER_ROLE.user),
//     MusicController.getTrending
// )

export const MusicRoutes = router;