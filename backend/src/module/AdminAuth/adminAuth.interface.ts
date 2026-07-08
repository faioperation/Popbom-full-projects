import { Model, Document } from "mongoose";
import { Types } from "mongoose";

export interface IAdmin {
    _id: Types.ObjectId;
    name?: string;
    email: string;
    role?: string;
    image?: string;
    password: string;
    passwordResetOTP?: string | null;
    passwordResetExpires?: Date | null;
    isOTPVerified?: boolean;
    createdAt?: Date;
    updatedAt?: Date;
}

export type TLoginAdmin = {
    email: string;
    password: string;
}

export interface AdminModel extends Model<IAdmin> {
    isAdminExistByEmail(email: string): Promise<(IAdmin & Document) | null>;
    isPasswordMatched(
        plainTextPassword: string,
        hashedPassword: string
    ): Promise<boolean>;
}




