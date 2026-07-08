import { z } from "zod";

export const generateTokenSchema = z.object({
  body: z.object({
    channel: z.string().min(1, "Channel name is required"),
    role: z.enum(["broadcaster", "audience"], {
      errorMap: () => ({ message: "Role must be 'broadcaster' or 'audience'" }),
    }),
  }),
});

export const startLiveSchema = z.object({
  body: z.object({
    channel: z.string().min(1, "Channel name is required"),
  }),
});

export const viewerJoinLeaveSchema = z.object({
  body: z.object({
    liveId: z.string().min(1, "Live ID is required"),
  }),
});

export const LiveValidation = {
  generateTokenSchema,
  startLiveSchema,
  viewerJoinLeaveSchema,
};
