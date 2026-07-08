import { Schema } from "mongoose";

export type ThemePreference = 'light' | 'dark';

export interface IUserSettings {
  userId: Schema.Types.ObjectId;
  themePreference: ThemePreference;
  notificationEnabled: boolean;
  createdAt?: Date;
  updatedAt?: Date;
}
