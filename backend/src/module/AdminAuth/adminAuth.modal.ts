import { Schema, model } from "mongoose";
import bcrypt from "bcrypt";
import { IAdmin, AdminModel } from "./adminAuth.interface";

const adminSchema = new Schema<IAdmin, AdminModel>(
  {
    name: { type: String },
    email: { type: String, required: true, unique: true },
    role: { type: String, enum: ["admin"], default: "admin" },
    password: { type: String, required: true },
    passwordResetOTP: { type: String, select: false, default: null },
    passwordResetExpires: { type: Date, select: false, default: null },
    isOTPVerified: { type: Boolean, default: false },
    image: { type: String },
  },
  { timestamps: true }
);

adminSchema.statics.isAdminExistByEmail = async function (email: string) {
  return this.findOne({ email }).select("+password");
};

adminSchema.statics.isPasswordMatched = async function (
  plainTextPassword: string,
  hashedPassword: string
) {
  return await bcrypt.compare(plainTextPassword, hashedPassword);
};

/* 🔹 Hash password before save */
adminSchema.pre("save", async function (next) {
  if (!this.isModified("password")) return next();
  this.password = await bcrypt.hash(this.password, 12);
  next();
});

export const Admin = model<IAdmin, AdminModel>("Admin", adminSchema);
