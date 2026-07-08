import { UserSettings } from "./userSettings.model";
import { IUserSettings } from "./userSettings.interface";
import AppError from "../../app/errors/AppError";
import status from "http-status";

const createOrUpdateSettings = async (userId: string, payload: Partial<IUserSettings>) => {
  const existing = await UserSettings.findOne({ userId });
  if (existing) {
    const updated = await UserSettings.findOneAndUpdate({ userId }, payload, { new: true, runValidators: true });
    return updated;
  } else {
    const newSettings = await UserSettings.create({ userId, ...payload });
    return newSettings;
  }
};

const getSettingsByUserId = async (userId: string) => {
  const settings = await UserSettings.findOne({ userId });
  if (!settings) throw new AppError(status.NOT_FOUND, 'User settings not found');
  return settings;
};

export const UserSettingsService = {
  createOrUpdateSettings,
  getSettingsByUserId,
};
