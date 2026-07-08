import config from "../../app/config"
import AppError from "../../app/errors/AppError";

const searchByText = async (query: string) => {
    const result = await fetch(`${config.ai_visual_search_api_url}/api/v1/search/by-text`, {
        method: "POST",
        body: JSON.stringify({ query }),
        headers: {
            "Content-Type": "application/json"
        }
    });
    const data = await result.json();
    if (result.status !== 200) {
        throw new AppError(result.status, data.detail);
    }
    return data;
}

const searchByImage = async (image: string) => {
    const result = await fetch(`${config.ai_visual_search_api_url}/api/v1/search/by-image`, {
        method: "POST",
        body: JSON.stringify({ image_url: image }),
        headers: {
            "Content-Type": "application/json"
        }
    })
    const data = await result.json();
    if (result.status !== 200) {
        throw new AppError(result.status, "Failed to search by image");
    }
    return data;
}

const searchByAudio = async (audio: string) => {
    const result = await fetch(`${config.ai_visual_search_api_url}/api/v1/search/by-audio`, {
        method: "POST",
        body: JSON.stringify({ audio_url: audio }),
        headers: {
            "Content-Type": "application/json"
        }
    });
    const data = await result.json();
    if (result.status !== 200) {
        throw new AppError(result.status, data.detail);
    }
    return data;
}
export const VisualSearchService = {
    searchByText,
    searchByImage,
    searchByAudio,
}