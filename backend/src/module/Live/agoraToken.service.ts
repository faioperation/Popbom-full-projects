import { RtcTokenBuilder, RtcRole } from "agora-access-token";
import config from "../../app/config";
import AppError from "../../app/errors/AppError";
import status from "http-status";
import { IGenerateTokenInput, ITokenResponse } from "./live.interface";

const generateAgoraToken = async (
    userId: string,
    input: IGenerateTokenInput
): Promise<ITokenResponse> => {
    const { channel, role } = input;

    // Validate Agora credentials
    if (!config.agora_app_id || !config.agora_app_certificate) {
        throw new AppError(
            status.INTERNAL_SERVER_ERROR,
            "Agora App ID and Certificate must be configured"
        );
    }

    // Generate UID from userId (convert to number for Agora)
    const uid = parseInt(userId.replace(/\D/g, "").slice(-9)) || 0;

    // Set role
    const agoraRole =
        role === "broadcaster" ? RtcRole.PUBLISHER : RtcRole.SUBSCRIBER;

    // Token expiration time (1 hour = 3600 seconds)
    const expirationTimeInSeconds = 3600;
    const currentTimestamp = Math.floor(Date.now() / 1000);
    const privilegeExpiredTs = currentTimestamp + expirationTimeInSeconds;

    // Generate token
    const token = RtcTokenBuilder.buildTokenWithUid(
        config.agora_app_id,
        config.agora_app_certificate,
        channel,
        uid,
        agoraRole,
        privilegeExpiredTs
    );

    return {
        token,
        channel,
        uid,
    };
};

export const AgoraTokenService = {
    generateAgoraToken,
};
