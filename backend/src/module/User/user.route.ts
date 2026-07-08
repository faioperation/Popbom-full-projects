import { Router } from "express";
import { UserController } from "./user.controller";
import auth from "../../app/middleware/auth";
import { USER_ROLE } from "./user.constant";
import validateRequest from "../../app/middleware/validateRequest";
import { UserValidation } from "./user.validation";
import upload from "../../app/middleware/upload";


const router = Router();

router.get(
    '/',
    auth(USER_ROLE.admin, USER_ROLE.user),
    UserController.getAllUsers
);

router.get(
    '/me',
    auth(USER_ROLE.admin, USER_ROLE.user),
    UserController.getMyProfile
)
router.get(
  '/alluser-with-follow-status',
  auth(USER_ROLE.user, USER_ROLE.admin),
  UserController.getAllUsersWithFollowStatus
);

router.get(
    '/gift-info/all',
    auth(USER_ROLE.admin, USER_ROLE.user),
    UserController.getAllGift
);
router.get(
  "/gift-info/:userId",
  auth(USER_ROLE.admin, USER_ROLE.user),
  UserController.getGiftInfoByUser
);

router.get(
  '/scan/:scanCode',
  auth(USER_ROLE.admin, USER_ROLE.user),
  UserController.getUserByScanCode
);

router.get(
    '/:userId',
    auth(USER_ROLE.admin, USER_ROLE.user),
    UserController.getSingleUser
)

router.patch(
  '/update-profile',
  auth(USER_ROLE.admin, USER_ROLE.user),
  upload.single('photo'),
  validateRequest(UserValidation.updateProfileValidationSchema),
  UserController.updateProfile,
);

router.patch(
  '/update-profile-photo',
  auth(USER_ROLE.admin, USER_ROLE.user),
  upload.single('photo'),
  validateRequest(UserValidation.updatePhotoValidationSchema),
  UserController.updateProfilePhoto,
);

router.patch(
  "/update-profile-password",
  auth(USER_ROLE.user, USER_ROLE.admin),
  UserController.updateProfilePassword
);


export const UserRoutes = router;