// import FormData from "form-data";
// import fs from "fs";
// import { IAiSendRequest } from "./aiVideo.interface";

// const generateVedio = async (data: IAiSendRequest, audioPath?: string) =>{

//     const formData = new FormData();
//     formData.append("file_type", data.file_type);

//     if (data.file_type === "text" && data.text) {
//       formData.append("text", data.text);
//     }

//     if (data.file_type === "audio" && audioPath) {
//       formData.append("file", fs.createReadStream(audioPath));
//     }

//     console.log(formData);

//     // const response = await axios.post(
//     //   process.env.AI_DEVELOPER_URL!,
//     //   formData,
//     //   {
//     //     headers: {
//     //       ...formData.getHeaders(),
//     //       Authorization: `Bearer ${process.env.AI_DEVELOPER_TOKEN}`,
//     //     },
//     //   }
//     // );

//     // return response.data;
//   }

// export const AiServices = {
//     generateVedio
// };