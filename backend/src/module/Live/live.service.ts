import mongoose from "mongoose";
import { Live } from "./live.model";
import {
    ICreateLiveInput,
    IActiveLiveResponse,
    IViewerJoinLeaveInput,
} from "./live.interface";
import { User } from "../User/user.modal";
import AppError from "../../app/errors/AppError";
import status from "http-status";
import { AgoraTokenService } from "./agoraToken.service";

const startLive = async (userId: string, data: ICreateLiveInput) => {
    // Check if user already has an active live
    const existingLive = await Live.findOne({
        userId: new mongoose.Types.ObjectId(userId),
        isLive: true,
    });

    if (existingLive) {
        throw new AppError(
            status.BAD_REQUEST,
            "You already have an active live broadcast"
        );
    }

    // Check if channel name is already taken
    const channelExists = await Live.findOne({
        channel: data.channel,
        isLive: true,
    });

    if (channelExists) {
        throw new AppError(
            status.BAD_REQUEST,
            "Channel name is already in use"
        );
    }

    // Create new live
    const live = await Live.create({
        userId: new mongoose.Types.ObjectId(userId),
        channel: data.channel,
        isLive: true,
        startedAt: new Date(),
        viewerCount: 0,
    });

    return live;
};

const endLive = async (userId: string, liveId: string) => {
    const live = await Live.findOne({
        _id: new mongoose.Types.ObjectId(liveId),
        userId: new mongoose.Types.ObjectId(userId),
        isLive: true,
    });

    if (!live) {
        throw new AppError(
            status.NOT_FOUND,
            "Live broadcast not found or already ended"
        );
    }

    live.isLive = false;
    live.endedAt = new Date();
    await live.save();

    return live;
};

const getActiveLives = async (): Promise<IActiveLiveResponse[]> => {
    const lives = await Live.find({ isLive: true })
        .sort({ createdAt: -1 })
        .populate({
            path: "userId",
            select: "username",
            populate: {
                path: "userDetails",
                select: "name photo",
            },
        })
        .lean();

    return Promise.all(
        lives.map(async (live: any) => {
            // Generate a random numeric UID for the audience token
            const uid = Math.floor(Math.random() * 900_000_000) + 100_000_000;
            const tokenResponse = await AgoraTokenService.generateAgoraToken(
                uid.toString(),
                {
                    channel: live.channel,
                    role: "audience",
                }
            );

            return {
                liveId: live._id.toString(),
                username: live.userId?.username || "Unknown",
                channel: live.channel,
                viewers: live.viewerCount || 0,
                userId: live.userId?._id?.toString() || "",
                startedAt: live.startedAt,
                agoraToken: tokenResponse.token,
                uid: tokenResponse.uid,
            };
        })
    );
};

const getLiveById = async (liveId: string) => {
    const live = await Live.findById(liveId)
        .populate({
            path: "userId",
            select: "username",
            populate: {
                path: "userDetails",
                select: "name photo",
            },
        })
        .lean();

    if (!live) {
        throw new AppError(status.NOT_FOUND, "Live broadcast not found");
    }

    return live;
};

const viewerJoin = async (liveId: string) => {
    const live = await Live.findById(liveId);

    if (!live || !live.isLive) {
        throw new AppError(
            status.NOT_FOUND,
            "Live broadcast not found or has ended"
        );
    }

    live.viewerCount = (live.viewerCount || 0) + 1;
    await live.save();

    return {
        viewerCount: live.viewerCount,
        liveId: live._id.toString(),
    };
};

const viewerLeave = async (liveId: string) => {
    const live = await Live.findById(liveId);

    if (!live || !live.isLive) {
        // Don't throw error if live doesn't exist - viewer might have left already
        return {
            viewerCount: 0,
            liveId,
        };
    }

    live.viewerCount = Math.max((live.viewerCount || 0) - 1, 0);
    await live.save();

    return {
        viewerCount: live.viewerCount,
        liveId: live._id.toString(),
    };
};

const getMyLive = async (userId: string) => {
    const live = await Live.findOne({
        userId: new mongoose.Types.ObjectId(userId),
        isLive: true,
    })
        .populate({
            path: "userId",
            select: "username",
            populate: {
                path: "userDetails",
                select: "name photo",
            },
        })
        .lean();

    return live;
};

export const LiveService = {
    startLive,
    endLive,
    getActiveLives,
    getLiveById,
    viewerJoin,
    viewerLeave,
    getMyLive,
};
