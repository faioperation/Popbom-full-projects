import { model, Schema } from "mongoose";
import { USER_ROLE, USER_STATUS } from "./user.constant";
import { TUser, UserModel } from "./user.interface";
import bcrypt from "bcrypt";
import config from "../../app/config";
import crypto from 'crypto';

const userSchema = new Schema(
  {
    // @ts-ignore
    username: {
      type: String,
      required: [true, "User name is required"],
      unique: true,
    },
    email: {
      type: String,
      required: true,
      match: [
        /^[^\s@]+@[^\s@]+\.[^\s@]+$/,
        "Please provide a valid email address",
      ],
    },
    mobile: {
      type: String,
      unique: true,
      sparse: true,
      default: undefined,
    },
    password: {
      type: String,
      required: true,
      select: false,
    },
    role: {
      type: String,
      enum: [USER_ROLE.user, USER_ROLE.admin],
      default: USER_ROLE.user,
    },
     provider: {
      type: String,
      enum: ['local', 'google', 'apple'],
      default: 'local'
    },
    googleId: {
      type: String,
      index: true,
      sparse: true,
      default: null,
    },
    appleId: {
      type: String,
      index: true,
      sparse: true,
      default: null,
    },
    points:{
      type:Number,
      default:100
    },
    status: {
      type: String,
      enum: USER_STATUS,
      default: "active",
    },
    isOTPVerified: {
      type: Boolean,
      default: false,
    },
    passwordChangeAt: {
      type: Date,
    },
    passwordResetOTP: {
      type: String,
      select: false,
      default: null,
    },
    passwordResetExpires: {
      type: Date,
      select: false,
      default: null,
    },

    scanCode:{
      type:String,
      unique:true,
      index:true
    },
  },
  {
    timestamps: true,
  }
);

// hash password before save
userSchema.pre("save", async function (next) {
  const user = this as any;

    if (user.isNew && !user.scanCode) {
    user.scanCode = crypto.randomBytes(8).toString("hex"); // e.g. "a3f92bc1d2e4f9ab"
  }

  if (!user.isModified("password")) {
    return next();
  }

  if (!user.password) {
    return next();
  }

  user.password = await bcrypt.hash(
    user.password,
    Number(config.bcrypt_salt_rounds)
  );
  next();
});

// remove password from returned doc
userSchema.post("save", function (doc: any, next) {
  doc.password = "";
  next();
});

// static methods
userSchema.statics.isUserExistByEmail = async function (email: string) {
  return await this.findOne({ email }).select(
    "+password +passwordResetOTP +passwordResetExpires"
  );
};

userSchema.statics.isUserExistByMobile = async function (mobile: string) {
  return await this.findOne({ mobile }).select(
    "+password +passwordResetOTP +passwordResetExpires"
  );
};

userSchema.statics.isPasswordMatched = async function (
  plainTextPassword: string,
  hashedPassword: string
) {
  return await bcrypt.compare(plainTextPassword, hashedPassword);
};

userSchema.statics.isJwtIssuedBeforePasswordChange = function (
  passwordChangeTimestamp: Date,
  jwtIssuuedTimestamp: number
) {
  const passwordChangeTime =
    new Date(passwordChangeTimestamp).getTime() / 1000;
  return passwordChangeTime > jwtIssuuedTimestamp;
};

// virtuals
userSchema.virtual("userDetails", {
  ref: "UserDetails",
  localField: "_id",
  foreignField: "userId",
  justOne: true,
});

userSchema.set("toJSON", { virtuals: true });
userSchema.set("toObject", { virtuals: true });

export const User = model<TUser, UserModel>("User", userSchema);
