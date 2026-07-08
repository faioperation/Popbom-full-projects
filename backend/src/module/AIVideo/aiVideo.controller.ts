// import { catchAsync } from "../../app/utils/catchAsync";
// import sendResponse from "../../app/utils/sendResponse";
// import status from "http-status";


// const generateVedio = catchAsync(async (req, res) => {
//   const text = req.body?.text || null;
//   const audioPath = req.file?.path || null;
//   console.log("REQ FILE:", req.file);
// console.log("REQ BODY:", req.body);


//   let file_type: "text" | "audio";

//   if (audioPath) {
//     console.log(audioPath);
//     file_type = "audio";
//   } else if (text) {
//     console.log(text);
//     file_type = "text";
//   } else {
//     return sendResponse(res, {
//       statusCode: status.BAD_REQUEST,
//       success: false,
//       message: "Send either text or audio as form-data",
//       data: null,
//     });
//   }

// //   const response = await AiServices.generateVedio(
// //     { file_type, text },
// //     audioPath || undefined
// //   );

// //   // Remove uploaded audio file from local storage
// //   if (audioPath) fs.unlinkSync(audioPath);

// //   sendResponse(res, {
// //     statusCode: status.OK,
// //     success: true,
// //     message: "AI response received",
// //     data: response,
// //   });
// });

// export const AiController = {
//   generateVedio
// };
