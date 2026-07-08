// import { Schema, model } from "mongoose";
// import { IAIVideoJob } from "./aiVideo.interface";

// const aiVideoSchema = new Schema<IAIVideoJob>(
//   {
//     userId: { type: Schema.Types.ObjectId, ref: "User", required: true },
//     inputText: { type: String, required: true },
//     language: { type: String, required: true },
//     scriptResponse: { type: Schema.Types.Mixed },
//     videoUrl: { type: String },
//     status: {
//       type: String,
//       enum: ["pending", "processing", "done", "failed"],
//       default: "pending",
//     },
//   },
//   { timestamps: true }
// );

// export const AIVideo = model<IAIVideoJob>("AIVideo", aiVideoSchema);
