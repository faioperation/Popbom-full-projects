import axios from "axios";
import { getSpotifyToken } from "../../app/utils/spotifyToken"
const playlist_id = "37i9dQZEVXbMDoHDwVN2tF"; 

const searchMusic = async (query:string) =>{
    const accessToken = await getSpotifyToken();

    const url = `https://api.spotify.com/v1/search?q=${query}&type=track&limit=5`;

    const res = await axios.get(url, {
        headers:{
            Authorization: `Bearer ${accessToken}`
        }
    });

    return res.data.tracks.items.map((t:any) =>({
        id:t.id,
        name:t.name,
        preview_url: t.preview_url,
        external_url: t.external_urls.spotify,
        artists:t.artists.map((a:any) => a.name),
        thumbnail:t.album.images?.[0]?.url,
    }));
};

// const getTrending = async () => {
//     const token = await getSpotifyToken();
//     console.log("Spotify token =", token);

//    const res = await axios.get(
//     "https://api.spotify.com/v1/browse/categories/toplists/playlists",
//     {
//       headers: { Authorization: `Bearer ${token}` },
//     }
//   );

//   console.log("Available Trending Playlists:", res.data.playlists.items);

//     return res.data.tracks.items.map((i: any) => ({
//       id: i.track.id,
//       name: i.track.name,
//       preview_url: i.track.preview_url,
//       external_url: i.track.external_urls.spotify,
//       artists: i.track.artists.map((a: any) => a.name),
//       thumbnail: i.track.album.images?.[0]?.url,
//     }));
//   };


export const MusicService ={
    searchMusic,
    // getTrending,
}