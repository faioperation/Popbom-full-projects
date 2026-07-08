import { catchAsync } from "../../app/utils/catchAsync";
import sendResponse from "../../app/utils/sendResponse";
import status from "http-status";
import { AgoraTokenService } from "./agoraToken.service";
import { LiveService } from "./live.service";
import { JwtPayload } from "jsonwebtoken";

// 1. Generate Agora Token
const generateToken = catchAsync(async (req, res) => {
  const user = req.user as JwtPayload;
  const { channel, role } = req.body;

  // Security: Only broadcaster role can generate broadcaster token
  if (role === "broadcaster") {
    // Verify user is authenticated
    if (!user || !user.id) {
      return sendResponse(res, {
        statusCode: status.UNAUTHORIZED,
        success: false,
        message: "Unauthorized. Only authenticated users can broadcast.",
        data: null,
      });
    }
  }

  const result = await AgoraTokenService.generateAgoraToken(user.id, {
    channel,
    role,
  });

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: "Agora token generated successfully",
    data: result,
  });
});

// 2. Start Live
const startLive = catchAsync(async (req, res) => {
  const user = req.user as JwtPayload;
  const { channel } = req.body;

  const live = await LiveService.startLive(user.id, { channel });

  sendResponse(res, {
    statusCode: status.CREATED,
    success: true,
    message: "Live broadcast started successfully",
    data: live,
  });
});

// 3. End Live
const endLive = catchAsync(async (req, res) => {
  const user = req.user as JwtPayload;
  // Try to get liveId from body first, then from params
  const liveId = req.body.liveId || req.params.liveId;

  if (!liveId) {
    return sendResponse(res, {
      statusCode: status.BAD_REQUEST,
      success: false,
      message: "Live ID is required",
      data: null,
    });
  }

  const live = await LiveService.endLive(user.id, liveId);

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: "Live broadcast ended successfully",
    data: live,
  });
});

// 4. Get Active Lives (Audience Screen)
const getActiveLives = catchAsync(async (req, res) => {
  const lives = await LiveService.getActiveLives();

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: "Active lives retrieved successfully",
    data: lives,
  });
});

// 5. Get Live by ID
const getLiveById = catchAsync(async (req, res) => {
  const { liveId } = req.params;
  const live = await LiveService.getLiveById(liveId);

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: "Live broadcast retrieved successfully",
    data: live,
  });
});

// 6. Viewer Join
const viewerJoin = catchAsync(async (req, res) => {
  const { liveId } = req.body;
  const result = await LiveService.viewerJoin(liveId);

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: "Viewer joined successfully",
    data: result,
  });
});

// 7. Viewer Leave
const viewerLeave = catchAsync(async (req, res) => {
  const { liveId } = req.body;
  const result = await LiveService.viewerLeave(liveId);

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: "Viewer left successfully",
    data: result,
  });
});

// 8. Get My Live (for broadcaster)
const getMyLive = catchAsync(async (req, res) => {
  const user = req.user as JwtPayload;

  const live = await LiveService.getMyLive(user.id);

  sendResponse(res, {
    statusCode: status.OK,
    success: true,
    message: "My live broadcast retrieved successfully",
    data: live || null,
  });
});

export const LiveController = {
  generateToken,
  startLive,
  endLive,
  getActiveLives,
  getLiveById,
  viewerJoin,
  viewerLeave,
  getMyLive,
};
