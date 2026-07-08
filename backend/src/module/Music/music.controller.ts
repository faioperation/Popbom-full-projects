import status from "http-status";
import { catchAsync } from "../../app/utils/catchAsync";
import sendResponse from "../../app/utils/sendResponse";
import { MusicService } from "./music.service";


const searchMusic = catchAsync(async (req, res) =>{
    const query = req.query.q as string;

    if(!query){
        return res.status(400).json({message:"Query is required"});
    }

    const tracks = await MusicService.searchMusic(query);

    sendResponse(res, {
        statusCode:status.OK,
        success:true,
        message:"Music search result fetched",
        data:tracks,
    });
});
// const getTrending = catchAsync(async (_req, res) => {
//   const tracks = await MusicService.getTrending();

//   sendResponse(res, {
//     statusCode: status.OK,
//     success: true,
//     message: "Trending songs fetched",
//     data: tracks,
//   });
// });

export const MusicController ={
    searchMusic,
    // getTrending
}