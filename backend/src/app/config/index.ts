import dotenv from 'dotenv';
import path from 'path';

dotenv.config({ path: path.join(process.cwd(), '.env') });

export default {
  NODE_ENV: process.env.NODE_ENV,
  port: process.env.PORT,
  database_url: process.env.DATABASE_URL,
  bcrypt_salt_rounds: process.env.BCRYPT_SALT_ROUNDS,
  jwt_access_secret: process.env.JWT_ACCESS_SECRET,
  jwt_access_expires_in: process.env.JWT_ACCESS_EXPIRES_IN,
  jwt_refresh_secret: process.env.JWT_REFRESH_SECRET,
  jwt_refresh_expires_in: process.env.JWT_REFRESH_EXPIRES_IN,
  email_user: process.env.EMAIL_USER,
  email_pass: process.env.EMAIL_PASS,

  spotify_client_id: process.env.SPOTIFY_CLIENT_ID,
  spotify_client_secret: process.env.SPOTIFY_CLIENT_SECRET,
  app_url: process.env.APP_URL || "http://172.252.13.97:5000",
  ai_recommendation_api_url: process.env.AI_RECOMMENDATION_API_URL,
  ai_visual_search_api_url: process.env.AI_VISUAL_SEARCH_API_URL,
  
  // Agora Configuration
  agora_app_id: process.env.AGORA_APP_ID,
  agora_app_certificate: process.env.AGORA_APP_CERTIFICATE,
};
