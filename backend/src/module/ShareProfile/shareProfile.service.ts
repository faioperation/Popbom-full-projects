import { User } from "../User/user.modal";
import AppError from "../../app/errors/AppError";
import status from "http-status";
import config from "../../app/config";

const getShareProfileDataFromDB = async (userId: string) => {
    const user = await User.findById(userId);

    if (!user) {
        throw new AppError(status.NOT_FOUND, "User not found");
    }

    // The Flutter application will use this URL to generate the QR code.
    // We return a public profile URL based on the username.
    const profileUrl = `${config.app_url}/profile/${user.username}`;

    return {
        profileUrl,
    };
};

const getShareProfileDataByUsername = async (username: string) => {
    const user = await User.findOne({ username }).populate('userDetails').lean();

    if (!user) {
        throw new AppError(status.NOT_FOUND, "User not found");
    }

    return {
        user
    };
};

export const ShareProfileServices = {
    getShareProfileDataFromDB,
    getShareProfileDataByUsername,
};
