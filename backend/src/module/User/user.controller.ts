import { Request, Response } from "express";
import { catchAsync } from "../../app/utils/catchAsync";
import { JwtPayload } from "jsonwebtoken";
import { UserServices } from "./user.service";
import sendResponse from "../../app/utils/sendResponse";
import status from "http-status";
import { User } from "./user.modal";
import AppError from "../../app/errors/AppError";

// profile info

const getSingleUser = catchAsync(async (req:Request, res:Response) =>{
    const { userId } = req.params;

    const result = await UserServices.getSingleUserFromDB(userId);

    sendResponse(res, {
        statusCode:status.OK,
        success:true,
        message:'User retrived successfully',
        data:result,
    });

});

const getMyProfile = catchAsync(async (req:Request, res:Response) =>{

    const user = req.user as JwtPayload;

    const result = await UserServices.getMyProfileInfo(user._id);

    sendResponse(res, {
        statusCode:status.OK,
        success:true,
        message:'User retrived successfully',
        data:result,
    });

});

const getAllUsers = catchAsync(async (req:Request, res: Response) =>{
    const result = await UserServices.getAllUsersFromDB();

    sendResponse(res, {
        statusCode:status.OK,
        success:true,
        message:'Users retrieved successfully',
        data:result
    });
});
const getAllGift = catchAsync(async (req:Request, res: Response) =>{
    const result = await UserServices.getOnlyGift();

    sendResponse(res, {
        statusCode:status.OK,
        success:true,
        message:'Users retrieved successfully',
        data:result
    });
});

const getGiftInfoByUser = catchAsync(async (req, res) => {
  const { userId } = req.params;

  const result = await UserServices.getGiftInfoByUserId(userId);

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: "User gift info retrieved successfully",
    data: result,
  });
});

const getAllUsersWithFollowStatus = catchAsync(async (req: Request, res: Response) => {
  const currentUser = req.user as JwtPayload;

  const users = await UserServices.getAllUsersWithFollowStatus(currentUser._id);

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: "Users retrieved successfully",
    data: users,
  });
});

const updateProfile = catchAsync(async (req, res) => {
 
  const user = req.user as JwtPayload;

  const photoUrl = req.file?.path;
  
  if(photoUrl){
    req.body.photo = photoUrl;
  }

  if(req.body.username){
    const existingUser = await User.findOne({ username: req.body.username});
    if(existingUser && existingUser._id.toString() !== user._id){
      throw new AppError(
        status.CONFLICT,
        'Username is already taken. Please choose another one.'
      )
    }
  }

  const result = await UserServices.updateProfile(user._id, req.body, user);

  // Send response
  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: 'User profile updated successfully',
    data: result,
  });
});

const updateProfilePhoto = catchAsync(async (req, res) => {

  const user = req.user as JwtPayload;
  const photoUrl = req.file?.path;
  
  if(photoUrl){
    req.body.photo = photoUrl;
  }
  const result = await UserServices.updateProfilePhoto(user._id, req.body, user);

  // Send response
  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: 'User profile photo updated successfully',
    data: result,
  });
});

const updateProfilePassword = catchAsync(async (req: Request, res: Response) => {
  const user = req.user;

  const result = await UserServices.updateProfileAndPassword(user, req.body);

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: "Profile and/or password updated successfully",
    data: result,
  });
});

const getUserByScanCode = catchAsync(async (req: Request, res: Response) => {
  const { scanCode } = req.params;

  const result = await UserServices.getUserByScanCodeFromDB(scanCode);

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: "User retrieved successfully",
    data: result,
  });
});


export const UserController ={
    getSingleUser,
    getMyProfile,
    getAllUsers,
    updateProfile,
    updateProfilePhoto,
    getAllUsersWithFollowStatus,
    updateProfilePassword,
    getUserByScanCode,
    getAllGift,
    getGiftInfoByUser
}