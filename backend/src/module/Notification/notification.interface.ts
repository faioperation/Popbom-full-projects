import { Types } from "mongoose";

export type TNotificationLinkType = 'chat' | 'post' | 'comment' | 'profile' | 'challenge' | 'gift' | 'follow';

export interface INotification {
  userId: Types.ObjectId | string; 
  senderId: Types.ObjectId | string; 
  type: string;
  message: string;
  linkType?: TNotificationLinkType;
  linkId?: Types.ObjectId | string;
  isRead: boolean;
  createdAt?: Date;
}

export interface INotificationPayload {
  userId: Types.ObjectId | string; 
  senderId: Types.ObjectId | string; 
  type: string;
  message: string;
  linkType?: TNotificationLinkType;
  linkId?: Types.ObjectId | string;
}