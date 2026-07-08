import { Schema } from "mongoose";

export interface ILive {
    userId: Schema.Types.ObjectId;
    channel: string;
    isLive: boolean;
    startedAt?: Date;
    endedAt?: Date;
    viewerCount: number;
    createdAt?: Date;
    updatedAt?: Date;
}

export interface ICreateLiveInput {
    channel: string;
}

export interface IGenerateTokenInput {
    channel: string;
    role: "broadcaster" | "audience";
}

export interface ITokenResponse {
    token: string;
    channel: string;
    uid: number | string;
}

export interface IActiveLiveResponse {
    liveId: string;
    username: string;
    channel: string;
    viewers: number;
    userId: string;
    startedAt: Date;
}

export interface IViewerJoinLeaveInput {
    liveId: string;
}
