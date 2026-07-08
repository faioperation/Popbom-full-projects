import { model, Schema } from "mongoose";
import { IUserSettings } from "./userSettings.interface";

const userSettingsSchema = new Schema<IUserSettings>(
  {
    userId: { type: Schema.Types.ObjectId, ref: 'User', required: true, unique: true },
    themePreference: { type: String, enum: ['light', 'dark'], default: 'light' },
    notificationEnabled: { type: Boolean, default: true },
  },
  { timestamps: true }
);

export const UserSettings = model<IUserSettings>('UserSettings', userSettingsSchema);
