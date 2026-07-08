import { Router } from "express";
import { TagController } from "./tag.controller";
import auth from "../../app/middleware/auth";
import { USER_ROLE } from "../User/user.constant";
import validateRequest from "../../app/middleware/validateRequest";
import { TagValidation } from "./tag.validation";

const router = Router();

router.post(
  '/',
  auth(USER_ROLE.user, USER_ROLE.admin),
  validateRequest(TagValidation.createTagSchema),
  TagController.createTag
);

router.get(
  '/',
  auth(USER_ROLE.user, USER_ROLE.admin),
  TagController.getAllTags
);

export const TagRoutes = router;