import { JwtPayload } from "jsonwebtoken";
import { User } from "./user.modal";
import AppError from "../../app/errors/AppError";
import status from "http-status";
import { IUserDetails } from "../UserDetails/userDetails.interface";
import { UserDetails } from "../UserDetails/userDetails.model";
import { Follow } from "../Follow/follow.model";
import { TUpdatePayload, TUserWithDetails } from "./user.interface";
import { Gift } from '../Gift/gift.model';
import { Types } from "mongoose";

const getSingleUserFromDB = async (userId:string) =>{

    const user = await User.findById(userId);

    if(!user) throw new AppError(status.NOT_FOUND, 'User not found');

    
    const userDetails = await UserDetails.findOne({ userId: user._id }).lean();

    return {
      _id:user._id,
      username: user.username,
      name:userDetails?.name,
      email: user.email,
      role: user.role,
      status: user.status,
      bio: userDetails?.bio,
      photo:userDetails?.photo,
      instaLink:userDetails?.instaLink,
      youtubeLink: userDetails?.youtubeLink,
    };
}

const getMyProfileInfo = async (userId:string) =>{

    const user = await User.findById(userId);

    if(!user) throw new AppError(status.NOT_FOUND, 'User not found');
    
    const userDetails = await UserDetails.findOne({ userId: user._id }).lean();
    return {
      id:user._id,
      username: user.username,
      name:userDetails?.name,
      email: user.email,
      role: user.role,
      status: user.status,
      bio: userDetails?.bio,
      photo:userDetails?.photo,
      instaLink:userDetails?.instaLink,
      youtubeLink: userDetails?.youtubeLink,
    };
}


const GIFT_TYPES = ['coin', 'heart', 'rose', 'star', 'fire'] as const;

const getAllUsersFromDB = async () => {
  // 1) fetch users (lean)
  const users = await User.find().sort({points:-1}).lean();

  if (!users?.length) {
    return [];
  }

  // 2) fetch userDetails for those users
  const userIds = users.map(u => u._id);
  const userDetailsList = await UserDetails.find({
    userId: { $in: userIds }
  }).lean();

  // 3) aggregate gift counts per userId and giftType in ONE query
  //    result shape: [{ _id: { userId: ObjectId(...), giftType: "coin" }, count: X }, ...]
  const giftAgg = await Gift.aggregate([
    { $match: { userId: { $in: userIds } } },
    { $group: { _id: { userId: '$userId', giftType: '$giftType' }, count: { $sum: 1 } } }
  ]);

  // 4) turn aggregation into a map: userId -> { coin: n, heart: m, ... }
  const giftMap = new Map<string, Record<string, number>>();
  giftAgg.forEach((row: any) => {
    const uid = row._id.userId.toString();
    const type = row._id.giftType as string;
    if (!giftMap.has(uid)) {
      const base: Record<string, number> = {};
      GIFT_TYPES.forEach(t => (base[t] = 0));
      giftMap.set(uid, base);
    }
    const rec = giftMap.get(uid)!;
    rec[type] = row.count;
  });

  // 5) assemble final result by mapping users and attaching details + gift counts
  const result = users.map(u => {
    const uid = u._id.toString();
    const details = userDetailsList.find(d => d.userId.toString() === uid) || {};

    // default counts (zero) if no gifts
    const counts = giftMap.get(uid) || GIFT_TYPES.reduce((acc, t) => {
      acc[t] = 0;
      return acc;
    }, {} as Record<string, number>);

    return {
      ...u,
      details,
      giftCounts: counts
    };
  });

  return result;
};

const getOnlyGift = async () => {
  
  const users = await User.find().sort({points:-1}).lean();

  if (!users?.length) {
    return [];
  }

  const userIds = users.map(u => u._id);
  const userDetailsList = await UserDetails.find({
    userId: { $in: userIds }
  }).lean();

  const giftAgg = await Gift.aggregate([
    { $match: { userId: { $in: userIds } } },
    { $group: { _id: { userId: '$userId', giftType: '$giftType' }, count: { $sum: 1 } } }
  ]);
  const giftMap = new Map<string, Record<string, number>>();
  giftAgg.forEach((row: any) => {
    const uid = row._id.userId.toString();
    const type = row._id.giftType as string;
    if (!giftMap.has(uid)) {
      const base: Record<string, number> = {};
      GIFT_TYPES.forEach(t => (base[t] = 0));
      giftMap.set(uid, base);
    }
    const rec = giftMap.get(uid)!;
    rec[type] = row.count;
  });

  const result = users.map(u => {
    const uid = u._id.toString();
    const counts = giftMap.get(uid) || GIFT_TYPES.reduce((acc, t) => {
      acc[t] = 0;
      return acc;
    }, {} as Record<string, number>);

    return {
      ...u,
      giftCounts: counts
    };
  });

  return result;
};

const getGiftInfoByUserId = async (userId: string) => {
  const user = await User.findById(userId).lean();
  if (!user) return null;

  const userDetails = await UserDetails.findOne({ userId }).lean();

  // gift aggregation
  const giftAgg = await Gift.aggregate([
    { $match: { userId: new Types.ObjectId(userId) } },
    { $group: { _id: "$giftType", count: { $sum: 1 } } }
  ]);

  const counts: Record<string, number> = {
    coin: 0,
    heart: 0,
    rose: 0,
    star: 0,
    fire: 0
  };

  giftAgg.forEach(row => {
    counts[row._id] = row.count;
  });

  return {
    ...user,
    giftCounts: counts,
  };
};


// const getAllUsersFromDB = async () =>{
//     const users = await User.find().lean();
//     const userDetailsList = await UserDetails.find({
//       userId:{$in: users.map(u => u._id)}
//     }).lean();

//     const result = users.map(user =>({
//       ...user,
//       details:userDetailsList.find(d => d.userId.toString() === user._id.toString() )|| {}
//     }));
    
//     return result;
// };

const getAllUsersWithFollowStatus = async (currentUserId: string) => {
  
  const users = await User.find({ _id: { $ne: currentUserId } })
    .select('username') 
    .populate({ path: 'userDetails', select: 'name photo' })
    .lean<TUserWithDetails[]>();

  const following = await Follow.find({ followingUserId: currentUserId }).select('followedUserId').lean();
  const followingIds = following.map(f => f.followedUserId.toString());

  const usersWithFollowStatus = users.map(u => ({
    userId:u._id,
    username:u.username,
    name:u.userDetails?.name ||"",
    photo:u.userDetails?.photo || "",
    isFollowing: followingIds.includes(u._id.toString())
  }));

  return usersWithFollowStatus;
};

const updateProfile = async (
  userId: string,
  payload: Partial<IUserDetails> & {username?:string},
  user: JwtPayload,
) => {
  
  const userData = await User.findOne({ _id: userId });

  if (!userData) throw new AppError(status.NOT_FOUND, 'User not found');

  if (userData.email !== user.email)
    throw new AppError(status.UNAUTHORIZED, 'You are not authorized!');

  // handle username separately
  if(payload.username && payload.username !== userData.username){
    const existingUser = await User.findOne({ username:payload.username });
    if(existingUser && existingUser._id.toString() !== user._id){
      throw new AppError(
        status.CONFLICT,
        'Username is already taken. Please choose another one.'
      );
    }
    userData.username = payload.username;
    await userData.save();
  }

  // Ensure the user can only update name, bio, instaLink, youtubeLink

  const allowedUpdates: (keyof IUserDetails)[] = [
    "name",
    "bio",
    "instaLink",
    "youtubeLink",
    "photo"
  ];
  const filteredUpdates: Partial<IUserDetails> = {};

  for (const key of allowedUpdates) {
    if (key in payload) {
      filteredUpdates[key] = payload[key] as never;
    }
  }

  const updatedUserDetails = await UserDetails.findOneAndUpdate({userId}, filteredUpdates, {
    new: true,
    runValidators: true,
  });
  
   return {
    userId: userData._id,
    username: userData.username,
    email: userData.email,
    role: userData.role,
    name: updatedUserDetails?.name,
    bio: updatedUserDetails?.bio,
    photo: updatedUserDetails?.photo,
    instaLink: updatedUserDetails?.instaLink,
    youtubeLink: updatedUserDetails?.youtubeLink,
  };
};


const updateProfilePhoto = async (
  userId: string,
  payload: Partial<IUserDetails>,
  user: JwtPayload,
) => {
  const userData = await User.findOne({ _id: userId });

  if (!userData) throw new AppError(status.NOT_FOUND, 'User not found');

  if (userData.email !== user.email)
    throw new AppError(status.UNAUTHORIZED, 'You are not authorized!');

  // // Ensure the user can only update photo

  const allowedUpdates: (keyof IUserDetails)[] = ['photo'];
  const filteredUpdates: Partial<IUserDetails> = {};

  for (const key of allowedUpdates) {
    if (key in payload) {
      filteredUpdates[key] = payload[key] as never;
    }
  }
  const updateUser = await UserDetails.findOneAndUpdate({userId}, filteredUpdates, {
    new: true,
    runValidators: true,
  });
  return updateUser?.photo;
};

const updateProfileAndPassword = async (userToken: JwtPayload | any, payload: TUpdatePayload) => {

  const identifier: any = {};

  if (userToken.userId) identifier._id = userToken.userId;
  else if (userToken.id) identifier._id = userToken.id;
  else if (userToken._id) identifier._id = userToken._id;
  else if (userToken.email) identifier.email = userToken.email;
  else throw new AppError(status.UNAUTHORIZED, "User identification failed");

  const needPassword = !!(payload.currentPassword || payload.newPassword);
  let userQuery = User.findOne(identifier);
  if (needPassword) userQuery = userQuery.select("+password");

  const user = await userQuery;
  if (!user) throw new AppError(status.NOT_FOUND, "User not found");

  if (payload.username && payload.username !== user.username) {
    const existing = await User.findOne({ username: payload.username }).lean();
    if (existing && existing._id.toString() !== user._id.toString()) {
      throw new AppError(status.CONFLICT, "Username already taken");
    }
    user.username = payload.username;
  }

  if (payload.email && payload.email !== user.email) {
    const existing = await User.findOne({ email: payload.email }).lean();
    if (existing && existing._id.toString() !== user._id.toString()) {
      throw new AppError(status.CONFLICT, "Email already in use");
    }
    user.email = payload.email;
  }

  if (payload.mobile && payload.mobile !== user.mobile) {
    const existing = await User.findOne({ mobile: payload.mobile }).lean();
    if (existing && existing._id.toString() !== user._id.toString()) {
      throw new AppError(status.CONFLICT, "Mobile already in use");
    }
    user.mobile = payload.mobile;
  }

  if (payload.currentPassword || payload.newPassword) {
    if (!payload.currentPassword || !payload.newPassword) {
      throw new AppError(status.BAD_REQUEST, "Both currentPassword and newPassword are required");
    }

    const hashed = (user as any).password;

    const isMatch = await User.isPasswordMatched(payload.currentPassword, hashed);
    if (!isMatch) throw new AppError(status.FORBIDDEN, "Current password is incorrect");

    const isSame = await User.isPasswordMatched(payload.newPassword, hashed);
    if (isSame) throw new AppError(status.BAD_REQUEST, "New password must be different");

    user.password = payload.newPassword;
    user.passwordChangeAt = new Date();
    user.passwordResetOTP = null;
    user.passwordResetExpires = null;
    user.isOTPVerified = false;
  }

  await user.save();

  if (payload.name) {
    await UserDetails.findOneAndUpdate(
      { userId: user._id },
      { name: payload.name },
      { new: true, upsert: true }
    );
  }

  const userDetails = await UserDetails.findOne({ userId: user._id }).lean();

  return {
    userId: user._id,
    username: user.username,
    email: user.email,
    mobile: user.mobile,
    role: user.role,
    name: userDetails?.name ?? "",
  };
};

const getUserByScanCodeFromDB = async (scanCode: string) => {
  const user = await User.findOne({ scanCode });

  if (!user) throw new AppError(status.NOT_FOUND, "User not found");

  const userDetails = await UserDetails.findOne({ userId: user._id }).lean();

  return {
    _id: user._id,
    username: user.username,
    name: userDetails?.name,
    email: user.email,
    role: user.role,
    status: user.status,
    bio: userDetails?.bio,
    photo: userDetails?.photo,
    instaLink: userDetails?.instaLink,
    youtubeLink: userDetails?.youtubeLink,
    scanCode: user.scanCode,
  };
};


export const UserServices = {
    getSingleUserFromDB,
    getMyProfileInfo,
    getAllUsersFromDB,
    getAllUsersWithFollowStatus,
    updateProfile,
    updateProfilePhoto,
    updateProfileAndPassword,
    getUserByScanCodeFromDB,
    getOnlyGift,
    getGiftInfoByUserId
}