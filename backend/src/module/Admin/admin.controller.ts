import { catchAsync } from "../../app/utils/catchAsync";
import sendResponse from "../../app/utils/sendResponse";
import status from "http-status";
import { AdminService } from "./admin.service";
import AppError from "../../app/errors/AppError";

const getDashboardData = catchAsync(async (req, res) => {
    const result = await AdminService.getDashboardData();
    sendResponse(res, {
        statusCode: status.OK,
        success: true,
        message: 'Dashboard data retrieved successfully',
        data: result
    });
});

const getAllUsersData = catchAsync(async (req, res) => {
    const result = await AdminService.getAllUsers();
    sendResponse(res, {
        statusCode: status.OK,
        success: true,
        message: 'All users retrieved successfully',
        data: result
    });
});

const getAllReportsData = catchAsync(async (req, res) => {
    const result = await AdminService.getAllReports();
    sendResponse(res, {
        statusCode: status.OK,
        success: true,
        message: 'All reports retrieved successfully',
        data: result
    });
});

const getAdminProfileData = catchAsync(async (req, res) => {
    const result = await AdminService.getAdminProfile(req.params.id);
    sendResponse(res, {
        statusCode: status.OK,
        success: true,
        message: 'Admin Profile retrieved successfully',
        data: result
    });
});

const updateAdminProfileData = catchAsync(async (req, res) => {
    const updateData: Record<string, any> = {};

    if (req.file) {
        const fileUrl = req.file.path || (req.file as any)?.secure_url;
        updateData.image = fileUrl;
    }

    if (req.body.name) {
        updateData.name = req.body.name;
    }

    if (req.body.email) {
        updateData.email = req.body.email;
    }

    if (Object.keys(updateData).length === 0) {
        throw new AppError(status.BAD_REQUEST, "No data provided to update");
    }

    const admin = await AdminService.updateAdminProfile(
        req.params.id,
        updateData
    );

    sendResponse(res, {
        statusCode: status.OK,
        success: true,
        message: "Admin Profile updated successfully",
        data: admin
    });
});

const changeAdminPasswordData = catchAsync(async (req, res) => {
    const { currentPassword, newPassword } = req.body;
    if(!currentPassword || !newPassword) throw new AppError(status.BAD_REQUEST, 'Current password and new password are required');
    const result = await AdminService.changeAdminPassword(req.params.id, { currentPassword, newPassword });
    sendResponse(res, {
        statusCode: status.OK,
        success: true,
        message: 'Admin password changed successfully',
        data: result
    });
});


export const AdminController = {
    getDashboardData,
    getAllUsersData,
    getAllReportsData,
    getAdminProfileData,
    updateAdminProfileData,
    changeAdminPasswordData,
};