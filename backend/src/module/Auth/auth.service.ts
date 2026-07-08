import status from "http-status";
import AppError from "../../app/errors/AppError";
import { User } from "../User/user.modal";
import { ChangePasswordPayload, TLoginUser, TRegisterUserPayload } from "./auth.interface";
import { createToken } from "./auth.utils";
import config from "../../app/config";
import jwt , { JwtPayload } from "jsonwebtoken";
import { generateOTP } from "../../app/utils/generateOtp";
import { sendEmail } from "../../app/utils/email";
import { UserDetails } from "../UserDetails/userDetails.model";


// FORGOT PASSWORD - Generate and email OTP
const forgotPassword = async (email: string) => {
  const user = await User.findOne({ email });

  if (!user) {
    throw new AppError(status.NOT_FOUND, 'User not found');
  }

  const otp = generateOTP();
  const otpExpiry = new Date(Date.now() + 15 * 60 * 1000); // 15 minutes

  user.passwordResetOTP = otp;
  user.passwordResetExpires = otpExpiry;
  user.isOTPVerified = false;

  await user.save();

  await sendEmail({
    to: user.email,
    subject: 'Your Password Reset OTP',
    text: `Your OTP for resetting password is: ${otp}. It expires in 15 minutes.`,
  });

  return true;
};

const verifyOTP =async({email,otp}:{email:string; otp:string})=>{
  const user = await User.findOne({ email }).select('+passwordResetOTP +passwordResetExpires');
  
  if(!user || !user.passwordResetOTP || !user.passwordResetExpires){
    throw new AppError(status.BAD_REQUEST,'Invalid password reset request');
  }

  if(user.passwordResetOTP !==otp){
    throw new AppError(status.UNAUTHORIZED,'Invalid OTP');
  }

  if(user.passwordResetExpires! < new Date()){
    throw new AppError(status.UNAUTHORIZED,'OTP has expired');
  }
  
  user.isOTPVerified = true;
  await user.save();

  return true;
}

// RESET PASSWORD - Verify OTP and update password
const resetPassword = async ({
  email,
  newPassword,
}: {
  email: string;
  newPassword: string;
}) => {
//   const user = await User.findOne({ email });
const user = await User.findOne({ email }).select('+isOTPVerified');

  if (!user || !user.isOTPVerified) {
    throw new AppError(status.BAD_REQUEST, 'OTP verification required before resetting password');
  }

  user.password = newPassword;
  user.passwordChangeAt = new Date();
  user.passwordResetOTP = null;
  user.passwordResetExpires = null;
  user.isOTPVerified = false;

  await user.save();

  return true;
};

const generateUniqueUsername = async (name: string): Promise<string> => {
  let baseUsername = name.trim().toLowerCase().replace(/\s+/g, '.');
  let username = baseUsername;
  let count = 1;

  while (await User.findOne({ username })) {
    count++;
    username = `${baseUsername}${count}`;
  }
  return username;
};


const registerUser = async (payload:TRegisterUserPayload) =>{
  const { name, email, mobile, password } = payload;

  const existingUser = await User.isUserExistByEmail(email);
    if(existingUser) throw new AppError(status.CONFLICT, 'User already exists!');

    const username = await generateUniqueUsername(name);

    const user = await User.create({
      username,
      email,
      mobile,
      password
    });

    await UserDetails.create({
      userId:user._id,
      name
    })

    return user;
};

const loginUser = async(payload:TLoginUser) =>{

    const user = await User.isUserExistByEmail(payload?.email);

    if(!user) throw new AppError(status.NOT_FOUND,'User not found');

    const isActive = user?.status;
    if(isActive ==='inactive')
        throw new AppError(status.UNAUTHORIZED,'User not active!');

    if(!(await User.isPasswordMatched(payload?.password, user?.password))){
        throw new AppError(status.FORBIDDEN,'Password not match');
    }

    const jwtPayload = {
        userId:user._id!.toString(),
        email:user?.email,
        role:user?.role,
    };

    const accessToken = createToken(jwtPayload, config.jwt_access_secret as string);

    const refreshToken = createToken(jwtPayload, config.jwt_refresh_secret as string);

    return {
        accessToken,
        refreshToken
    };

};

const refreshToken = async(token:string) =>{
    const decoded = jwt.verify(token, config.jwt_refresh_secret as string) as JwtPayload;

    const { email, iat } = decoded;

    const user = await User.isUserExistByEmail(email);
    if(!user){
        throw new AppError(status.NOT_FOUND, 'This user is not found!');
    }

    const userStatus = user?.status;
    if(userStatus ==='inactive'){
        throw new AppError(status.FORBIDDEN, 'This user is not active!');
    }

    if(user.passwordChangeAt && User.isJwtIssuedBeforePasswordChange(user.passwordChangeAt, iat as number))
        {
        throw new AppError(
            status.UNAUTHORIZED, "You are unauthorized!"
        );
    }

    const jwtPayload = {
       userId:user._id!.toString(),
        email: user?.email,
        role: user?.role
    };

    const accessToken = createToken(
        jwtPayload, config.jwt_access_secret as string
    );

    return {
        accessToken
    };
};

const logoutUser = async (refreshToken: string) =>{
    const result = await User.findOneAndUpdate(
        {refreshToken},
        { refreshToken: null},
        { new: true},
    );
    return result;
};


const changePassword = async (user: JwtPayload | any, payload: ChangePasswordPayload) => {
 
  const userData = await User.findOne({email:user.email}).select("+password");
  
  if (!userData) throw new AppError(status.NOT_FOUND, "User not found");

  const isMatch = await User.isPasswordMatched(payload.currentPassword, userData.password);
  if (!isMatch) throw new AppError(status.FORBIDDEN, "Current password is incorrect");

  const isSame = await User.isPasswordMatched(payload.newPassword, userData.password);
  if (isSame) throw new AppError(status.BAD_REQUEST, "New password must be different from current password");

  userData.password = payload.newPassword;
  userData.passwordChangeAt = new Date();

  userData.passwordResetOTP = null;
  userData.passwordResetExpires = null;
  userData.isOTPVerified = false;

  await userData.save();

  return { message: "Password changed successfully" };
};

export const AuthService ={
    registerUser,
    loginUser,
    refreshToken,
    logoutUser,
    forgotPassword,
    resetPassword,
    verifyOTP,
    changePassword,
    generateUniqueUsername
}