import config from "../../app/config";
import AppError from "../../app/errors/AppError";

const getFeedForUser = async (userId: string) => {
    const feed = await fetch(`${config.ai_recommendation_api_url}/api/v1/feed/foryou/${userId}`, {
        method: "GET",
        headers: {
            "Content-Type": "application/json"
        }
    });
    const data = await feed.json();
    if (feed.status !== 200) {
        throw new AppError(feed.status, data.message || "Failed to get feed");
    }
    return data;
}

const getStemFeed = async (userId: string) => {

    const stemFeed = await fetch(`${config.ai_recommendation_api_url}/api/v1/feed/stream/stem/${userId}`, {
        method: "GET",
        headers: {
            "Content-Type": "application/json"
        }
    });
    const data = await stemFeed.json();
    if (data?.length === 0) {
        throw new AppError(404, "No stem feed found");
    }
    return data;
}
export const AiRecommendationService = {
    getFeedForUser,
    getStemFeed
}