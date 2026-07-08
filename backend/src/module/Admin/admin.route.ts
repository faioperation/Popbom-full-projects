import { Router } from "express";
import adminAuth from "../../app/middleware/adminAuth";
import { AdminController } from "./admin.controller";
import upload from "../../app/middleware/upload";

const router = Router();

router.get("/dashboard", adminAuth, AdminController.getDashboardData);

router.get("/users", adminAuth, AdminController.getAllUsersData);

router.get("/reports", adminAuth, AdminController.getAllReportsData);

router.get("/profile/:id", adminAuth, AdminController.getAdminProfileData);

router.patch("/profile/:id", adminAuth, upload.single('image'), AdminController.updateAdminProfileData);

router.put("/profile/change-password/:id", adminAuth, AdminController.changeAdminPasswordData);

export const AdminRoutes = router;