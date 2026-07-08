{
    "email":"admin@gmail.com",
    "password":"Admin@12345"
}
# Pop Bom API Documentation

A comprehensive social media platform API built with Node.js, Express, TypeScript, and MongoDB. This API supports features like posts, stories, challenges, chat, reactions, comments, and more.

## Table of Contents

- [Getting Started](#getting-started)
- [Authentication](#authentication)
- [API Routes](#api-routes)
  - [Auth Routes](#auth-routes)
  - [User Routes](#user-routes)
  - [Post Routes](#post-routes)
  - [Comment Routes](#comment-routes)
  - [Post Reaction Routes](#post-reaction-routes)
  - [Saved Post Routes](#saved-post-routes)
  - [Shared Post Routes](#shared-post-routes)
  - [Story Routes](#story-routes)
  - [Story Reaction Routes](#story-reaction-routes)
  - [Story Reply Routes](#story-reply-routes)
  - [Challenge Routes](#challenge-routes)
  - [Challenge Participant Routes](#challenge-participant-routes)
  - [Post Watch History Routes](#post-watch-history-routes)
  - [Post Watch Count Routes](#post-watch-count-routes)
  - [Follow Routes](#follow-routes)
  - [Tag Routes](#tag-routes)
  - [Post Tag Routes](#post-tag-routes)
  - [Tag People Routes](#tag-people-routes)
  - [Music Routes](#music-routes)
  - [Chat Routes](#chat-routes)
  - [Report Routes](#report-routes)
  - [Point Routes](#point-routes)
  - [Gift Routes](#gift-routes)
  - [Notification Routes](#notification-routes)
  - [User Settings Routes](#user-settings-routes)
- [Socket.IO Events](#socketio-events)
- [Environment Variables](#environment-variables)

## Getting Started

### Prerequisites

Before running the project, ensure you have the following installed:

- **Node.js** (v14 or higher) - [Download here](https://nodejs.org/)
- **MongoDB** - [Download here](https://www.mongodb.com/try/download/community) or use [MongoDB Atlas](https://www.mongodb.com/cloud/atlas) (cloud)
- **npm** (comes with Node.js) or **yarn**

### Step-by-Step Setup

#### 1. Clone or Navigate to the Project

```bash
cd Popbom
```

#### 2. Install Dependencies

```bash
npm install
```

This will install all required packages listed in `package.json`.

#### 3. Set Up Environment Variables

Create a `.env` file in the root directory of the project:

```bash
# Create .env file (Windows)
type nul > .env

# Create .env file (Linux/Mac)
touch .env
```

Add the following environment variables to your `.env` file:

```env
NODE_ENV=development
PORT=5000
DATABASE_URL=mongodb://localhost:27017/popbom
BCRYPT_SALT_ROUNDS=12
JWT_ACCESS_SECRET=your_super_secret_access_key_here
JWT_ACCESS_EXPIRES_IN=1d
JWT_REFRESH_SECRET=your_super_secret_refresh_key_here
JWT_REFRESH_EXPIRES_IN=7d
EMAIL_USER=your_email@example.com
EMAIL_PASS=your_email_app_password
SPOTIFY_CLIENT_ID=your_spotify_client_id
SPOTIFY_CLIENT_SECRET=your_spotify_client_secret
CLOUDINARY_CLOUD_NAME=your_cloudinary_cloud_name
CLOUDINARY_API_KEY=your_cloudinary_api_key
CLOUDINARY_API_SECRET=your_cloudinary_api_secret
```

**Important Notes:**
- Replace `your_super_secret_access_key_here` and `your_super_secret_refresh_key_here` with strong, random strings
- For MongoDB: Use `mongodb://localhost:27017/popbom` for local MongoDB, or use a MongoDB Atlas connection string for cloud
- Email credentials are needed for password reset functionality
- Spotify credentials are needed for music search functionality
- **Cloudinary credentials are REQUIRED for file uploads (videos, images)**: 
  - Sign up at [Cloudinary](https://cloudinary.com/)
  - Get your `cloud_name`, `api_key`, and `api_secret` from your dashboard
  - Without these, file uploads will fail

#### 4. Start MongoDB

**Option A: Local MongoDB**
```bash
# Windows (if MongoDB is installed as a service, it should start automatically)
# Or start manually:
mongod

# Linux/Mac
sudo systemctl start mongod
# or
mongod
```

**Option B: MongoDB Atlas (Cloud)**
- No local setup needed, just use your Atlas connection string in `DATABASE_URL`

#### 5. Run the Project

**For Development (with hot reload):**
```bash
npm run start:dev
```

**For Production:**
```bash
# First, build the TypeScript code
npm run build

# Then start the server
npm start
```

#### 6. Verify the Server is Running

Once started, you should see:
```
App listening on port http://localhost:5000
```

You can test the API by visiting:
- `http://localhost:5000` - Should return "Pop Bom is running"
- `http://localhost:5000/api` - API base endpoint

### Available Scripts

```bash
# Development mode (with auto-reload)
npm run start:dev

# Build TypeScript to JavaScript
npm run build

# Start production server
npm start

# Run linter
npm run lint

# Fix linting issues
npm run lint:fix

# Format code with Prettier
npm run format
```

### Troubleshooting

**Port Already in Use:**
- Change the `PORT` in your `.env` file to a different port (e.g., 5001, 3000)

**MongoDB Connection Error:**
- Ensure MongoDB is running: `mongod` or check MongoDB service status
- Verify your `DATABASE_URL` in `.env` is correct
- For MongoDB Atlas, ensure your IP is whitelisted

**Module Not Found Errors:**
- Delete `node_modules` and `package-lock.json`, then run `npm install` again

**TypeScript Errors:**
- Run `npm run build` to see detailed error messages
- Ensure all dependencies are installed: `npm install`

## Authentication

Most routes require authentication using JWT tokens. Include the token in the Authorization header:

```
Authorization: Bearer <your_access_token>
```

User roles:
- `user`: Regular user
- `admin`: Administrator

## API Routes

Base URL: `/api`

---

### Auth Routes

Base path: `/api/auth`

#### POST `/api/auth/register`
Register a new user.

**Body Parameters:**
```json
{
  "name": "string (required)",
  "email": "string (required, valid email)",
  "mobile": "string (optional, valid phone number)",
  "password": "string (required)"
}
```

#### POST `/api/auth/login`
Login user.

**Body Parameters:**
```json
{
  "email": "string (required)",
  "password": "string (required)"
}
```

#### POST `/api/auth/refresh-token`
Refresh access token.

**Cookies:**
- `refreshToken`: string (required)

#### POST `/api/auth/logout`
Logout user.

**Authentication:** Required (user, admin)

#### POST `/api/auth/forgot-password`
Request password reset OTP.

**Body Parameters:**
```json
{
  "email": "string (required, valid email)"
}
```

#### POST `/api/auth/verify-otp`
Verify OTP for password reset.

**Body Parameters:**
```json
{
  "email": "string (required, valid email)",
  "otp": "string (required)"
}
```

#### POST `/api/auth/reset-password`
Reset password after OTP verification.

**Body Parameters:**
```json
{
  "email": "string (required, valid email)",
  "newPassword": "string (required, min 6 characters)"
}
```

#### POST `/api/auth/change-password`
Change password (authenticated user).

**Authentication:** Required (user, admin)

**Body Parameters:**
```json
{
  "currentPassword": "string (required, min 6 characters)",
  "newPassword": "string (required, min 6 characters)"
}
```

#### POST `/api/auth/google`
Google OAuth authentication.

**Body Parameters:**
```json
{
  "idToken": "string (required)"
}
```

#### POST `/api/auth/apple`
Apple OAuth authentication.

**Body Parameters:**
```json
{
  "identityToken": "string (required)",
  "fullName": {
    "givenName": "string (optional)",
    "familyName": "string (optional)"
  }
}
```

---

### User Routes

Base path: `/api/users`

#### GET `/api/users`
Get all users.

**Authentication:** Required (user, admin)

#### GET `/api/users/me`
Get current user's profile.

**Authentication:** Required (user, admin)

#### GET `/api/users/alluser-with-follow-status`
Get all users with follow status.

**Authentication:** Required (user, admin)

#### GET `/api/users/gift-info/all`
Get all gift information.

**Authentication:** Required (user, admin)

#### GET `/api/users/gift-info/:userId`
Get gift information for a specific user.

**Authentication:** Required (user, admin)

**URL Parameters:**
- `userId`: string (required)

#### GET `/api/users/scan/:scanCode`
Get user by scan code.

**Authentication:** Required (user, admin)

**URL Parameters:**
- `scanCode`: string (required)

#### GET `/api/users/:userId`
Get single user by ID.

**Authentication:** Required (user, admin)

**URL Parameters:**
- `userId`: string (required)

#### PATCH `/api/users/update-profile`
Update user profile.

**Authentication:** Required (user, admin)

**Body Parameters:**
```json
{
  "name": "string (optional)"
}
```

**Form Data:**
- `photo`: File (optional, image file)

#### PATCH `/api/users/update-profile-photo`
Update profile photo only.

**Authentication:** Required (user, admin)

**Form Data:**
- `photo`: File (required, image file)

#### PATCH `/api/users/update-profile-password`
Update profile password.

**Authentication:** Required (user, admin)

---

### Post Routes

Base path: `/api/posts`

#### POST `/api/posts`
Create a new post.

**Authentication:** Required (user, admin)

**Form Data:**
- `video`: File (required, video file)
- `title`: string (required)
- `body`: string (optional)
- `challengeId`: string (optional)
- `musicUrl`: string (optional)
- `location`: string (optional)
- `postType`: "reels" | "challenges" | "story" (required)
- `audience`: "everyone" | "follower" (optional, default: "everyone")
- `hashTagIds`: string (optional, JSON array as string) - **Note:** Use `hashTagIds` (array of tag IDs), not `hashTagNames`
- `tagPeople`: string (optional, JSON array as string)

#### GET `/api/posts`
Get feed posts.

**Authentication:** Required (user, admin)

#### GET `/api/posts/my-posts`
Get logged-in user's posts.

**Authentication:** Required (user, admin)

#### GET `/api/posts/user-posts/:userId`
Get posts by user ID.

**Authentication:** Required (user, admin)

**URL Parameters:**
- `userId`: string (required)

#### GET `/api/posts/tagged/:userId`
Get tagged posts for a user.

**Authentication:** Required (user, admin)

**URL Parameters:**
- `userId`: string (required)

#### GET `/api/posts/:id`
Get single post by ID.

**URL Parameters:**
- `id`: string (required)

#### PATCH `/api/posts/:id`
Update post.

**Authentication:** Required (user, admin)

**URL Parameters:**
- `id`: string (required)

**Body Parameters:**
```json
{
  "title": "string (optional)",
  "body": "string (optional)",
  "musicUrl": "string (optional)",
  "location": "string (optional)",
  "audience": "everyone" | "follower" (optional)
}
```

#### DELETE `/api/posts/:postId`
Delete post.

**Authentication:** Required (user, admin)

**URL Parameters:**
- `postId`: string (required)

---

### Comment Routes

Base path: `/api/comments`

#### POST `/api/comments`
Create a comment.

**Authentication:** Required (user, admin)

**Body Parameters:**
```json
{
  "postId": "string (required)",
  "comment": "string (required)",
  "parentCommentId": "string (optional)"
}
```

#### GET `/api/comments/post/:postId`
Get comments by post ID.

**URL Parameters:**
- `postId`: string (required)

#### PATCH `/api/comments/:id`
Update comment.

**Authentication:** Required (user, admin)

**URL Parameters:**
- `id`: string (required)

**Body Parameters:**
```json
{
  "comment": "string (required)"
}
```

#### DELETE `/api/comments/:id`
Delete comment.

**Authentication:** Required (user, admin)

**URL Parameters:**
- `id`: string (required)

---

### Post Reaction Routes

Base path: `/api/post-reactions`

#### POST `/api/post-reactions`
React to a post.

**Authentication:** Required (user, admin)

**Body Parameters:**
```json
{
  "postId": "string (required)",
  "reaction": "heart" | "like" | "sad" | "happy" | "angry" (required),
  "challengeId": "string (optional)"
}
```

#### GET `/api/post-reactions/reactions/total/:userId`
Get total reactions for a user.

**Authentication:** Required (user, admin)

**URL Parameters:**
- `userId`: string (required)

#### GET `/api/post-reactions/post/:postId`
Get reactions by post ID.

**URL Parameters:**
- `postId`: string (required)

#### GET `/api/post-reactions/:userId`
Get reactions by user ID.

**URL Parameters:**
- `userId`: string (required)

#### DELETE `/api/post-reactions/:id`
Delete reaction.

**Authentication:** Required (user, admin)

**URL Parameters:**
- `id`: string (required)

---

### Saved Post Routes

Base path: `/api/saved-posts`

#### POST `/api/saved-posts`
Save a post.

**Authentication:** Required (user, admin)

**Body Parameters:**
```json
{
  "postId": "string (required)"
}
```

#### GET `/api/saved-posts/user`
Get saved posts for logged-in user.

**Authentication:** Required (user, admin)

#### GET `/api/saved-posts/:id`
Get saved post by ID.

**Authentication:** Required (user, admin)

**URL Parameters:**
- `id`: string (required)

#### DELETE `/api/saved-posts/:id`
Delete saved post.

**Authentication:** Required (user, admin)

**URL Parameters:**
- `id`: string (required)

---

### Shared Post Routes

Base path: `/api/shared-posts`

#### POST `/api/shared-posts`
Share a post.

**Authentication:** Required (user, admin)

**Body Parameters:**
```json
{
  "postId": "string (required)"
}
```

#### GET `/api/shared-posts/:postId`
Get shared posts by post ID.

**URL Parameters:**
- `postId`: string (required)

#### GET `/api/shared-posts/user/:userId`
Get shared posts by user ID.

**URL Parameters:**
- `userId`: string (required)

---

### Story Routes

Base path: `/api/stories`

#### GET `/api/stories`
Get story feed.

**Authentication:** Required (user, admin)

#### GET `/api/stories/user/:userId`
Get stories by user ID.

**URL Parameters:**
- `userId`: string (required)

#### GET `/api/stories/user`
Get logged-in user's stories.

**Authentication:** Required (user, admin)

#### DELETE `/api/stories/:id`
Delete story.

**Authentication:** Required (user, admin)

**URL Parameters:**
- `id`: string (required)

---

### Story Reaction Routes

Base path: `/api/story-reaction`

#### POST `/api/story-reaction`
React to a story.

**Authentication:** Required (user, admin)

**Body Parameters:**
```json
{
  "storyId": "string (required)",
  "reaction": "heart" | "like" | "sad" | "happy" | "angry" (required)
}
```

#### GET `/api/story-reaction/story/:storyId`
Get reactions by story ID.

**URL Parameters:**
- `storyId`: string (required)

#### GET `/api/story-reaction/user/:userId`
Get reactions by user ID.

**URL Parameters:**
- `userId`: string (required)

#### DELETE `/api/story-reaction/:id`
Delete story reaction.

**Authentication:** Required (user, admin)

**URL Parameters:**
- `id`: string (required)

---

### Story Reply Routes

Base path: `/api/story-reply`

#### POST `/api/story-reply`
Create a reply to a story.

**Authentication:** Required (user, admin)

**Body Parameters:**
```json
{
  "storyId": "string (required)",
  "reply": "string (required)"
}
```

#### GET `/api/story-reply/story/:storyId`
Get replies by story ID.

**URL Parameters:**
- `storyId`: string (required)

#### GET `/api/story-reply/user/:userId`
Get replies by user ID.

**URL Parameters:**
- `userId`: string (required)

#### DELETE `/api/story-reply/:id`
Delete story reply.

**Authentication:** Required (user, admin)

**URL Parameters:**
- `id`: string (required)

---

### Challenge Routes

Base path: `/api/challenges`

#### POST `/api/challenges`
Create a challenge.

**Authentication:** Required (user, admin)

**Form Data:**
- `challengePoster`: File (optional, image file)
- `challengeName`: string (required)
- `challengeDesc`: string (required)
- `challengeStartDate`: string (required, ISO date)
- `challengeEndDate`: string (required, ISO date)
- `rules`: string (optional, JSON array as string)

#### GET `/api/challenges/all`
Get all challenges.

**Authentication:** Required (user)

#### GET `/api/challenges/my`
Get my created challenges.

**Authentication:** Required (user)

#### GET `/api/challenges/participated`
Get challenges I participated in.

**Authentication:** Required (user)

#### GET `/api/challenges/:id`
Get challenge by ID.

**Authentication:** Required (user, admin)

**URL Parameters:**
- `id`: string (required)

#### PATCH `/api/challenges/:id`
Update challenge.

**Authentication:** Required (user, admin)

**URL Parameters:**
- `id`: string (required)

**Body Parameters:**
```json
{
  "challengeName": "string (optional)",
  "challengeDesc": "string (optional)",
  "challengeStartDate": "string (optional, ISO date)",
  "challengeEndDate": "string (optional, ISO date)",
  "rules": "array (optional)"
}
```

#### DELETE `/api/challenges/:id`
Delete challenge.

**Authentication:** Required (user, admin)

**URL Parameters:**
- `id`: string (required)

---

### Challenge Participant Routes

Base path: `/api/challenge-participants`

#### POST `/api/challenge-participants`
Add participant to challenge.

**Authentication:** Required (user, admin)

**Body Parameters:**
```json
{
  "challengeId": "string (required)",
  "postId": "string (required)"
}
```

#### GET `/api/challenge-participants/challenge/:challengeId`
Get participants by challenge ID.

**URL Parameters:**
- `challengeId`: string (required)

#### GET `/api/challenge-participants/user/:userId`
Get challenges by user ID.

**URL Parameters:**
- `userId`: string (required)

#### DELETE `/api/challenge-participants/:id`
Remove participant.

**Authentication:** Required (user, admin)

**URL Parameters:**
- `id`: string (required)

---

### Post Watch History Routes

Base path: `/api/post-watch`

#### POST `/api/post-watch/record`
Record a watch/view.

**Authentication:** Required (user, admin)

**Body Parameters:**
```json
{
  "postId": "string (required)"
}
```

#### GET `/api/post-watch/user/:userId`
Get watch history by user ID.

**Authentication:** Required (user, admin)

**URL Parameters:**
- `userId`: string (required)

**Query Parameters:**
- `page`: number (optional)
- `limit`: number (optional)

#### GET `/api/post-watch/post/:postId`
Get watch records by post ID.

**URL Parameters:**
- `postId`: string (required)

**Query Parameters:**
- `page`: number (optional)
- `limit`: number (optional)

#### GET `/api/post-watch/:id`
Get watch record by ID.

**Authentication:** Required (user, admin)

**URL Parameters:**
- `id`: string (required)

#### DELETE `/api/post-watch/:id`
Delete watch record.

**Authentication:** Required (user, admin)

**URL Parameters:**
- `id`: string (required)

---

### Post Watch Count Routes

Base path: `/api/post-watch-count`

#### POST `/api/post-watch-count/increment`
Increment watch count.

**Authentication:** Required (user, admin)

**Body Parameters:**
```json
{
  "postId": "string (required)",
  "amount": "number (optional, default: 1)"
}
```

#### GET `/api/post-watch-count/:postId`
Get watch count by post ID.

**URL Parameters:**
- `postId`: string (required)

#### PATCH `/api/post-watch-count/set`
Set watch count (admin only).

**Authentication:** Required (admin)

**Body Parameters:**
```json
{
  "postId": "string (required)",
  "count": "number (required)"
}
```

#### DELETE `/api/post-watch-count/:postId`
Reset watch count to zero (admin only).

**Authentication:** Required (admin)

**URL Parameters:**
- `postId`: string (required)

---

### Follow Routes

Base path: `/api/follow`

#### POST `/api/follow/toggle`
Toggle follow/unfollow.

**Authentication:** Required (user, admin)

**Body Parameters:**
```json
{
  "followedUserId": "string (required)"
}
```

#### GET `/api/follow/followers/:userId`
Get followers for a user.

**URL Parameters:**
- `userId`: string (required)

#### GET `/api/follow/following/:userId`
Get following list for a user.

**URL Parameters:**
- `userId`: string (required)

#### GET `/api/follow/is-following`
Check if following a user.

**Authentication:** Required (user, admin)

**Query Parameters:**
- `targetId`: string (required)

#### DELETE `/api/follow/:id`
Unfollow by follow record ID.

**Authentication:** Required (user, admin)

**URL Parameters:**
- `id`: string (required)

---

### Tag Routes

Base path: `/api/tag`

#### POST `/api/tag`
Create a tag.

**Authentication:** Required (user, admin)

**Body Parameters:**
```json
{
  "tagName": "string (required)"
}
```

#### GET `/api/tag`
Get all tags.

**Authentication:** Required (user, admin)

---

### Post Tag Routes

Base path: `/api/post-tag` (Note: This route is not registered in main routes, but exists in codebase)

#### GET `/api/post-tag/post/:postId`
Get tags for a post.

**URL Parameters:**
- `postId`: string (required)

#### GET `/api/post-tag/tag/:tagId`
Get posts by tag ID.

**URL Parameters:**
- `tagId`: string (required)

#### DELETE `/api/post-tag/:id`
Delete post tag by ID.

**Authentication:** Required (user, admin)

**URL Parameters:**
- `id`: string (required)

#### DELETE `/api/post-tag`
Delete post tag by post and tag.

**Authentication:** Required (user, admin)

**Body Parameters:**
```json
{
  "postId": "string (required)",
  "tagId": "string (required)"
}
```

---

### Tag People Routes

Base path: `/api/tag-people` (Note: This route is not registered in main routes, but exists in codebase)

#### POST `/api/tag-people`
Tag a user in a post.

**Authentication:** Required (user, admin)

**Body Parameters:**
```json
{
  "postId": "string (required)",
  "userId": "string (required)"
}
```

#### GET `/api/tag-people/post/:postId`
Get tagged users for a post.

**Authentication:** Required (user, admin)

**URL Parameters:**
- `postId`: string (required)

#### GET `/api/tag-people/user/:userId`
Get posts where a user was tagged.

**Authentication:** Required (user, admin)

**URL Parameters:**
- `userId`: string (required)

#### DELETE `/api/tag-people/:id`
Delete tag by ID.

**Authentication:** Required (user, admin)

**URL Parameters:**
- `id`: string (required)

#### DELETE `/api/tag-people`
Delete tag by post and user.

**Authentication:** Required (user, admin)

**Body Parameters:**
```json
{
  "postId": "string (required)",
  "userId": "string (required)"
}
```

---

### Music Routes

Base path: `/api/music`

#### GET `/api/music/search`
Search for music.

**Authentication:** Required (user, admin)

**Query Parameters:**
- `q`: string (required) - Search query

---

### Chat Routes

Base path: `/api/chat`

#### POST `/api/chat/start`
Start or find a conversation.

**Authentication:** Required (user, admin)

**Body Parameters:**
```json
{
  "otherUserId": "string (required)"
}
```

#### GET `/api/chat`
Get all conversations for logged-in user.

**Authentication:** Required (user, admin)

#### GET `/api/chat/:conversationId/messages`
Get messages for a conversation.

**Authentication:** Required (user, admin)

**URL Parameters:**
- `conversationId`: string (required)

**Query Parameters:**
- `limit`: number (optional, default: 50)
- `before`: string (optional, message ID for pagination)

#### POST `/api/chat/send`
Send a message.

**Authentication:** Required (user, admin)

**Body Parameters:**
```json
{
  "conversationId": "string (optional, if not provided, toUserId is required)",
  "toUserId": "string (optional, if conversationId not provided)",
  "text": "string (optional)",
  "mediaUrl": "string (optional)"
}
```

#### PATCH `/api/chat/:conversationId/read`
Mark messages as read.

**Authentication:** Required (user, admin)

**URL Parameters:**
- `conversationId`: string (required)

---

### Report Routes

Base path: `/api/report`

#### POST `/api/report`
Create a report.

**Authentication:** Required (user, admin)

**Body Parameters:**
```json
{
  "category": "string (required, min 1 character)",
  "shortTitle": "string (required, min 1, max 150 characters)",
  "description": "string (required, min 10 characters)"
}
```

#### GET `/api/report`
Get all reports.

**Authentication:** Required (user)

**Query Parameters:**
- `page`: string (optional)
- `limit`: string (optional)
- `status`: "open" | "in_progress" | "resolved" | "closed" (optional)
- `category`: string (optional)
- `userId`: string (optional)
- `from`: string (optional, date)
- `to`: string (optional, date)

#### GET `/api/report/:id`
Get report by ID.

**Authentication:** Required (user, admin)

**URL Parameters:**
- `id`: string (required)

#### PATCH `/api/report/:id`
Update report (admin only).

**Authentication:** Required (admin)

**URL Parameters:**
- `id`: string (required)

**Body Parameters:**
```json
{
  "status": "open" | "in_progress" | "resolved" | "closed" (optional),
  "adminResponse": "string (optional, nullable)",
  "isReadByAdmin": "boolean (optional)"
}
```

#### DELETE `/api/report/:id`
Delete report (admin only).

**Authentication:** Required (admin)

**URL Parameters:**
- `id`: string (required)

---

### Point Routes

Base path: `/api/point`

#### GET `/api/point/:userId`
Get user points.

**Authentication:** Required (user, admin)

**URL Parameters:**
- `userId`: string (required)

#### GET `/api/point/:userId/history`
Get point history for a user.

**Authentication:** Required (user, admin)

**URL Parameters:**
- `userId`: string (required)

---

### Gift Routes

Base path: `/api/gift`

#### POST `/api/gift`
Send a gift.

**Authentication:** Required (user, admin)

**Body Parameters:**
```json
{
  "userId": "string (required)",
  "giftType": "coin" | "heart" | "rose" | "star" | "fire" (required)
}
```

---

### Notification Routes

Base path: `/api/notification` (Note: This route is not registered in main routes, but exists in codebase)

#### POST `/api/notification`
Create a notification.

**Authentication:** Required (user, admin)

**Body Parameters:**
```json
{
  "userId": "string (required)",
  "notificationBody": "string (required)"
}
```

#### GET `/api/notification/user/:userId`
Get notifications for a user.

**Authentication:** Required (user, admin)

**URL Parameters:**
- `userId`: string (required)

---

### User Settings Routes

Base path: `/api/user-settings` (Note: This route is not registered in main routes, but exists in codebase)

#### POST `/api/user-settings/:userId`
Create or update user settings.

**Authentication:** Required (user, admin)

**URL Parameters:**
- `userId`: string (required)

**Body Parameters:**
```json
{
  "themePreference": "light" | "dark" (optional),
  "notificationEnabled": "boolean (optional)"
}
```

#### GET `/api/user-settings/:userId`
Get user settings.

**Authentication:** Required (user, admin)

**URL Parameters:**
- `userId`: string (required)

---

## Socket.IO Events

The application uses Socket.IO for real-time communication. Connect to the server and authenticate using:

```javascript
const socket = io("http://localhost:PORT", {
  auth: { token: "Bearer <ACCESS_TOKEN>" }
});
```

### Client Events

#### `join_conversation`
Join a conversation room.

**Payload:**
```json
{
  "conversationId": "string (required)"
}
```

#### `chat:send`
Send a message via socket (alternative to REST API).

**Payload:**
```json
{
  "conversationId": "string (optional)",
  "toUserId": "string (optional, required if conversationId not provided)",
  "text": "string (optional)",
  "mediaUrl": "string (optional)"
}
```

#### `chat:typing`
Send typing indicator.

**Payload:**
```json
{
  "conversationId": "string (required)",
  "isTyping": "boolean (required)"
}
```

#### `chat:read`
Mark messages as read.

**Payload:**
```json
{
  "conversationId": "string (required)"
}
```

### Server Events

#### `chat:receive`
Receive a new message.

**Payload:**
```json
{
  "conversationId": "string",
  "message": { /* message object */ }
}
```

#### `notification:new_message`
Notification for new message (sent to personal room).

**Payload:**
```json
{
  "conversationId": "string",
  "message": { /* message object */ }
}
```

#### `chat:typing`
Typing indicator from another user.

**Payload:**
```json
{
  "userId": "string",
  "conversationId": "string",
  "isTyping": "boolean"
}
```

#### `chat:read`
Messages marked as read by another user.

**Payload:**
```json
{
  "userId": "string",
  "conversationId": "string"
}
```

---

## Environment Variables

Create a `.env` file in the root directory with the following variables:

```env
NODE_ENV=development
PORT=5000
DATABASE_URL=mongodb://localhost:27017/popbom
BCRYPT_SALT_ROUNDS=12
JWT_ACCESS_SECRET=your_access_secret
JWT_ACCESS_EXPIRES_IN=1d
JWT_REFRESH_SECRET=your_refresh_secret
JWT_REFRESH_EXPIRES_IN=7d
EMAIL_USER=your_email@example.com
EMAIL_PASS=your_email_password
SPOTIFY_CLIENT_ID=your_spotify_client_id
SPOTIFY_CLIENT_SECRET=your_spotify_client_secret
```

---

## Technologies Used

- **Node.js** - Runtime environment
- **Express** - Web framework
- **TypeScript** - Programming language
- **MongoDB** - Database
- **Mongoose** - ODM
- **JWT** - Authentication
- **Socket.IO** - Real-time communication
- **Cloudinary** - File storage
- **Zod** - Schema validation
- **Multer** - File upload handling
- **Bcrypt** - Password hashing
- **Nodemailer** - Email service
- **Spotify API** - Music integration
- **OpenAI** - AI features
- **Deepgram** - Speech recognition

---

## Project Structure

```
src/
├── app/
│   ├── config/          # Configuration files
│   ├── errors/         # Error handling
│   ├── interfaces/     # TypeScript interfaces
│   ├── middleware/     # Express middleware
│   ├── routes/         # Route definitions
│   └── utils/          # Utility functions
├── module/             # Feature modules
│   ├── Auth/          # Authentication
│   ├── User/          # User management
│   ├── Post/          # Posts
│   ├── Comment/       # Comments
│   ├── Chat/          # Chat functionality
│   └── ...            # Other modules
├── app.ts             # Express app setup
└── server.ts          # Server entry point
```

---

## License

ISC

---

## Author

Pop Bom Development Team

