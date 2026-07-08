import axios from "axios";
import config from "../config";
import qs from "qs";

let cachedToken ="";
let tokenExpiresAt = 0;

export const getSpotifyToken = async () =>{
    const now = Date.now();

    if(cachedToken && now < tokenExpiresAt){
        return cachedToken;
    }

    const tokenUrl ="https://accounts.spotify.com/api/token";

    const headers = {
        "Content-Type":"application/x-www-form-urlencoded",
        Authorization:
        "Basic " +
        Buffer.from(
            `${config.spotify_client_id}:${config.spotify_client_secret}`
        ).toString("base64")
    };

    const data = qs.stringify({grant_type:"client_credentials"});

    const response = await axios.post(tokenUrl, data, {headers});

    cachedToken = response.data.access_token;

    tokenExpiresAt = now +response.data.expires_in*1000;

    return cachedToken;
}