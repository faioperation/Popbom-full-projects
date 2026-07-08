/* eslint-disable no-unused-vars */

import { Model, Types } from "mongoose";
import { USER_ROLE } from "./user.constant";


type Role ='user'|'admin';
type Status ='active'| 'inactive';

export interface TUser {
    _id?:Types.ObjectId;
    isOTPVerified?: boolean
    username:string;
    email:string;
    password:string;
    mobile?: string;
    role: Role;
    provider?: 'local' | 'google' | 'apple';
    googleId?: string | null;
    appleId?: string | null;
    status:Status;
    passwordChangeAt?:Date;
    passwordResetOTP?: string | null;
    passwordResetExpires?: Date | null;
    createdAt?:Date;
    updatedAt?:Date;

    scanCode?:string;
    points?:number;
}

export type TUserWithDetails = {
  _id: string;
  username: string;
  userDetails?: {
    name?: string;
    photo?: string;
  };
};

export type TUpdatePayload = {
  username?: string;
  name?: string;
  email?: string;
  mobile?: string;
  currentPassword?: string;
  newPassword?: string;
};
    
export interface UserModel extends Model<TUser>{
    isUserExistByEmail(email:string):Promise<TUser | null>;

    isPasswordMatched(
        plainTextPassword:string,
        hashedPassword:string
    ):Promise<boolean>;

    isJwtIssuedBeforePasswordChange(
        passwordChangeTimestamp:Date,
        jwtIssuuedTimestamp:number,
    ): boolean;
}

export type TUserRole = keyof typeof USER_ROLE;