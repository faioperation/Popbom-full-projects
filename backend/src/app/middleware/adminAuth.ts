import { NextFunction, Request, Response } from "express";
import config from "../config";
import { verifyToken } from "../../module/AdminAuth/adminAuth.utils";
import { Admin } from "../../module/AdminAuth/adminAuth.modal";
import AppError from "../errors/AppError";
import httpStatus from "http-status";
import { catchAsync } from "../utils/catchAsync";
import { CLIENT_RENEG_LIMIT } from "tls";

const adminAuth = catchAsync(async (req: Request, res: Response, next: NextFunction) => {

    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
        throw new AppError(httpStatus.UNAUTHORIZED, "Unauthorized");
    }   
    const token = authHeader.split(" ")[1];

    const decoded = verifyToken(token, config.jwt_access_secret as string);

    if (!decoded || !decoded.email) {
        throw new AppError(httpStatus.UNAUTHORIZED, "Unauthorized");
    }

    const admin = await Admin.isAdminExistByEmail(decoded.email);

    if (!admin) {
        throw new AppError(httpStatus.UNAUTHORIZED, "Unauthorized");
    }

    if (admin.role !== "admin") {
        throw new AppError(httpStatus.FORBIDDEN, "Admin access required");
    }

    (req as any).admin = admin;

    next();
});


export default adminAuth;