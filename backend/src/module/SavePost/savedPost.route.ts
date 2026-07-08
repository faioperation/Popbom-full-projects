import { Router } from "express";
import auth from "../../app/middleware/auth";
import { USER_ROLE } from "../User/user.constant";
import { SavedPostController } from "./savedPost.controller";

const router = Router();


router.post("/", auth(USER_ROLE.user, USER_ROLE.admin), SavedPostController.savePost);

router.get("/user", auth(USER_ROLE.user, USER_ROLE.admin), SavedPostController.getSavedByUser);

router.get("/:id", auth(USER_ROLE.user, USER_ROLE.admin), SavedPostController.getSavedById);

router.delete("/:id", auth(USER_ROLE.user, USER_ROLE.admin), SavedPostController.deleteSaved);

export const SavedPostRoutes = router;
