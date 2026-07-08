import { Post } from "../Post/post.model";
import { User } from "../User/user.modal";
import { ReportModel } from "../Report/report.model";
import { Admin } from "../AdminAuth/adminAuth.modal";
import AppError from "../../app/errors/AppError";
import status from "http-status";

const getDashboardData = async () => {
    const users = await User.countDocuments();
    const posts = await Post.countDocuments();
    const reports = await ReportModel.countDocuments();
    const totalUsers = await User.find().select('email status createdAt updatedAt').lean();
    return {
        users,
        posts,
        reports,
        totalUsers,
    };
};

const getAllUsers = async () => {
    const users = await User.find().select('email username status mobile createdAt').lean();
    return users;
};

const getAllReports = async () => {
    const todaysReportsCount = await ReportModel.countDocuments({ createdAt: { $gte: new Date(new Date().setHours(0, 0, 0, 0)), $lte: new Date(new Date().setHours(23, 59, 59, 999)) } });

    const onProgressReportsCount = await ReportModel.countDocuments({ status: 'in_progress' });
    const completedReportsCount = await ReportModel.countDocuments({ status: 'resolved' });

    const reports = await ReportModel.find()
        .select('userId category shortTitle description status adminResponse isReadByAdmin createdAt')
        .populate({
            path: 'userId',
            select: 'email name'
        })
        .lean();

    return {
        todaysReportsCount,
        onProgressReportsCount,
        completedReportsCount,
        reports,
    };
};

const getAdminProfile = async (id: string) => {
    const admin = await Admin.findById(id).select('name email role image createdAt updatedAt').lean();
    if (!admin) throw new AppError(status.NOT_FOUND, 'Admin not found');
    return admin;
};

const updateAdminProfile = async (id: string, body: any) => {
    const admin = await Admin.findByIdAndUpdate(
        id,
        { $set: body },
        { new: true, runValidators: true }
    )
        .select("name email role image createdAt updatedAt")
        .lean();

    if (!admin) {
        throw new AppError(status.NOT_FOUND, "Admin not found");
    }

    return admin;
};

const changeAdminPassword = async (id: string, body: any) => {
    const admin = await Admin.findById(id).select('+password');
    if (!admin) throw new AppError(status.NOT_FOUND, 'Admin not found');
    const isPasswordMatched = await Admin.isPasswordMatched(body.currentPassword, admin.password);
    if (!isPasswordMatched) throw new AppError(status.FORBIDDEN, 'Current password is incorrect');
    const isSame = await Admin.isPasswordMatched(body.newPassword, admin.password);
    if (isSame) throw new AppError(status.BAD_REQUEST, 'New password must be different from current password');
    admin.password = body.newPassword;
    await admin.save();
    return 'Password changed successfully';
};

export const AdminService = {
    getDashboardData,
    getAllUsers,
    getAllReports,
    getAdminProfile,
    updateAdminProfile,
    changeAdminPassword,
};