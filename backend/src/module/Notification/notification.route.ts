import { Router } from "express";
import { NotificationController } from "./notification.controller";
import auth from "../../app/middleware/auth";
import { USER_ROLE } from "../User/user.constant";
import validateRequest from "../../app/middleware/validateRequest";
import { NotificationValidation } from "./notification.validation";

const router = Router();

router.post(
  '/',
  auth(USER_ROLE.user, USER_ROLE.admin),
  validateRequest(NotificationValidation.createNotificationSchema),
  NotificationController.createNotification
);

router.get(
  '/user/:userId',
  auth(USER_ROLE.user, USER_ROLE.admin),
  NotificationController.getUserNotifications
);

router.patch(
  '/:id/read',
  auth(USER_ROLE.user, USER_ROLE.admin),
  NotificationController.markAsRead
);

export const NotificationRoutes = router;
