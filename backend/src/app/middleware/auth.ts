/* eslint-disable @typescript-eslint/no-unused-vars */
/* eslint-disable no-unused-vars */
import { NextFunction, Request, Response } from "express";
import { catchAsync } from "../utils/catchAsync";
import AppError from "../errors/AppError";
import httpStatus from 'http-status';
import config from "../config";
import jwt, { JwtPayload } from 'jsonwebtoken';
import { TUserRole } from "../../module/User/user.interface";
import { User } from "../../module/User/user.modal";


const auth = (...requiredRoles: TUserRole[]) => {
    return catchAsync(async (req: Request, res: Response, next: NextFunction) => {

        const token = req.headers.authorization?.split(' ')[1];
        
        // checking if the token is missing
        if (!token) {
            throw new AppError(httpStatus.UNAUTHORIZED, 'Your are not authorized!');
        }

        let decoded;

        try {
            // check if the gien token is valid
            decoded = jwt.verify(
                token,
                config.jwt_access_secret as string
            ) as JwtPayload;
        } catch (error) {

            throw new AppError(httpStatus.UNAUTHORIZED, 'Unauthorized');
        }

        const { role, email } = decoded;


        // checking if the user is exist
        const user = await User.isUserExistByEmail(email);
        if (!user) {
            throw new AppError(httpStatus.NOT_FOUND, 'This user is not exist');
        }

        if (requiredRoles && !requiredRoles.includes(role)) {
            throw new AppError(
                httpStatus.UNAUTHORIZED,
                'Your are not authorized!!'
            );
        }
        req.user = user;
        next();
    })
};

export default auth;