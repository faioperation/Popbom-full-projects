# OAuth Login Testing Guide for Postman

## Prerequisites

Before testing, ensure you have:
1. ✅ Server running (check your PORT in `.env` file)
2. ✅ Environment variables set:
   - `GOOGLE_CLIENT_ID` - Your Google OAuth Client ID
   - `APPLE_CLIENT_ID` - Your Apple OAuth Client ID (Bundle ID)
   - `JWT_ACCESS_SECRET` - JWT access token secret
   - `JWT_REFRESH_SECRET` - JWT refresh token secret

## API Endpoints

- **Base URL**: `http://localhost:YOUR_PORT` (or your server URL)
- **Google Login**: `POST /api/auth/google`
- **Apple Login**: `POST /api/auth/apple`

---

## 🔵 Testing Google Login

### Step 1: Get Google ID Token

You need a valid Google ID Token. Here are two ways to get it:

#### Option A: Using Google OAuth Playground (Easiest for Testing)
1. Go to: https://developers.google.com/oauthplayground/
2. Click the gear icon (⚙️) in top right
3. Check "Use your own OAuth credentials"
4. Enter your `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET`
5. In the left panel, find "Google OAuth2 API v2"
6. Select: `https://www.googleapis.com/auth/userinfo.email` and `https://www.googleapis.com/auth/userinfo.profile`
7. Click "Authorize APIs"
8. Sign in with your Google account
9. Click "Exchange authorization code for tokens"
10. Copy the `id_token` value

#### Option B: Using a Test Client Application
If you have a frontend app configured with Google Sign-In, you can:
1. Sign in with Google in your app
2. Get the `idToken` from the response
3. Use that token in Postman

### Step 2: Test in Postman

**Request Setup:**
- **Method**: `POST`
- **URL**: `http://localhost:YOUR_PORT/api/auth/google`
- **Headers**:
  ```
  Content-Type: application/json
  ```
- **Body** (raw JSON):
  ```json
  {
    "idToken": "YOUR_GOOGLE_ID_TOKEN_HERE"
  }
  ```

### Step 3: Expected Response (Success)

**Status Code**: `200 OK`

**Response Body**:
```json
{
  "success": true,
  "statusCode": 200,
  "message": "Google login successful",
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

**Cookies**:
- `refreshToken` cookie will be set automatically (httpOnly, secure in production)

### Step 4: Verify Success Indicators

✅ **Status Code**: 200  
✅ **Response contains**: `accessToken`  
✅ **Cookie set**: `refreshToken` (check Cookies tab in Postman)  
✅ **Message**: "Google login successful"  
✅ **User created/updated**: Check your database for the user with `googleId` field populated

---

## 🍎 Testing Apple Login

### Step 1: Get Apple Identity Token

Apple Sign-In requires more setup. You need:

1. **Apple Developer Account** with Sign in with Apple capability enabled
2. **Service ID** configured in Apple Developer Portal
3. **Private Key** (.p8 file) for your App ID
4. **Client Secret** generated using your private key

#### Getting Apple Identity Token:

**Option A: Using Apple's Test Environment**
1. Configure Sign in with Apple in your Apple Developer account
2. Use Apple's test credentials or a real iOS/macOS app
3. Get the `identityToken` from the Apple Sign-In response

**Option B: Using a Test Client**
If you have a frontend app with Apple Sign-In configured:
1. Sign in with Apple in your app
2. Get the `identityToken` from the response
3. Use that token in Postman

**Note**: Apple tokens are harder to test manually. Consider using a test iOS app or Apple's testing tools.

### Step 2: Test in Postman

**Request Setup:**
- **Method**: `POST`
- **URL**: `http://localhost:YOUR_PORT/api/auth/apple`
- **Headers**:
  ```
  Content-Type: application/json
  ```
- **Body** (raw JSON) - First Time Sign-In:
  ```json
  {
    "identityToken": "YOUR_APPLE_IDENTITY_TOKEN_HERE",
    "fullName": {
      "givenName": "John",
      "familyName": "Doe"
    }
  }
  ```

- **Body** (raw JSON) - Subsequent Sign-Ins (fullName optional):
  ```json
  {
    "identityToken": "YOUR_APPLE_IDENTITY_TOKEN_HERE"
  }
  ```

### Step 3: Expected Response (Success)

**Status Code**: `200 OK`

**Response Body**:
```json
{
  "success": true,
  "statusCode": 200,
  "message": "Apple login successful",
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

**Cookies**:
- `refreshToken` cookie will be set automatically

### Step 4: Verify Success Indicators

✅ **Status Code**: 200  
✅ **Response contains**: `accessToken`  
✅ **Cookie set**: `refreshToken`  
✅ **Message**: "Apple login successful"  
✅ **User created/updated**: Check your database for the user with `appleId` field populated

---

## ❌ Common Error Responses

### Invalid Token Error
```json
{
  "success": false,
  "statusCode": 401,
  "message": "Failed to verify Google token" // or "Failed to verify Apple token"
}
```
**Solution**: Check that your token is valid and not expired

### Missing Email Error (Google)
```json
{
  "success": false,
  "statusCode": 400,
  "message": "Email is required from Google"
}
```
**Solution**: Ensure Google account has verified email

### Email Not Verified Error (Google)
```json
{
  "success": false,
  "statusCode": 401,
  "message": "Google email is not verified"
}
```
**Solution**: Verify your Google account email

### Missing Email Error (Apple - New User)
```json
{
  "success": false,
  "statusCode": 400,
  "message": "Email is required for account creation. Please ensure your OAuth provider returns an email address."
}
```
**Solution**: Apple should provide email on first sign-in. Ensure your Apple Developer configuration includes email scope.

---

## 🔍 How to Verify Everything Works

### 1. Check Database
After successful login, verify in your database:
- User record exists
- `provider` field is set to `'google'` or `'apple'`
- `googleId` or `appleId` is populated
- `email` field is set
- `username` is auto-generated

### 2. Test Token Usage
Use the returned `accessToken` to access protected routes:
- Add header: `Authorization: Bearer YOUR_ACCESS_TOKEN`
- Test a protected endpoint (e.g., `/api/users/profile`)

### 3. Test Refresh Token
- The `refreshToken` cookie should be set
- Use it with `/api/auth/refresh-token` endpoint to get a new access token

### 4. Test User Linking
- If a user exists with the same email but different provider, the account should be linked
- Check that both `googleId` and `appleId` can be set on the same user

---

## 📝 Postman Collection Setup

### Environment Variables (Recommended)
Create a Postman environment with:
- `base_url`: `http://localhost:YOUR_PORT`
- `google_id_token`: Your Google ID token
- `apple_identity_token`: Your Apple identity token
- `access_token`: Will be set after login

### Pre-request Script (Optional)
For Google login, you can add a script to validate token format:
```javascript
if (!pm.environment.get("google_id_token")) {
    throw new Error("Google ID Token is required");
}
```

### Tests Script (Optional)
Add tests to verify response:
```javascript
pm.test("Status code is 200", function () {
    pm.response.to.have.status(200);
});

pm.test("Response has accessToken", function () {
    var jsonData = pm.response.json();
    pm.expect(jsonData.data).to.have.property('accessToken');
});

pm.test("Refresh token cookie is set", function () {
    pm.expect(pm.cookies.has('refreshToken')).to.be.true;
});
```

---

## 🚀 Quick Test Checklist

### Google Login
- [ ] Server is running
- [ ] `GOOGLE_CLIENT_ID` is set in `.env`
- [ ] Valid Google ID token obtained
- [ ] POST request to `/api/auth/google` with `idToken`
- [ ] Receive 200 status with `accessToken`
- [ ] `refreshToken` cookie is set
- [ ] User exists in database with `googleId`

### Apple Login
- [ ] Server is running
- [ ] `APPLE_CLIENT_ID` is set in `.env`
- [ ] Apple Sign-In configured in Apple Developer
- [ ] Valid Apple identity token obtained
- [ ] POST request to `/api/auth/apple` with `identityToken`
- [ ] Receive 200 status with `accessToken`
- [ ] `refreshToken` cookie is set
- [ ] User exists in database with `appleId`

---

## 💡 Tips

1. **Token Expiration**: OAuth tokens expire quickly. Get fresh tokens for each test.

2. **Cookie Visibility**: In Postman, check the "Cookies" tab below the response to see if `refreshToken` cookie is set.

3. **Database Verification**: Always check your database after successful login to ensure user is created/updated correctly.

4. **Error Messages**: Read error messages carefully - they will tell you exactly what's wrong.

5. **First vs Subsequent Logins**: 
   - First login creates a new user
   - Subsequent logins find existing user by `googleId`/`appleId`
   - If email matches existing user, accounts are linked

6. **Testing Production**: When testing in production, ensure:
   - `NODE_ENV=production` is set
   - Cookies use `secure: true` and `sameSite: 'none'`
   - HTTPS is enabled

---

## 🐛 Troubleshooting

### "Failed to verify Google token"
- Token might be expired
- `GOOGLE_CLIENT_ID` might not match the token's audience
- Token format might be incorrect

### "Failed to verify Apple token"
- Token might be expired
- `APPLE_CLIENT_ID` (Bundle ID) might not match
- Apple Developer configuration might be incorrect

### Cookie not setting
- Check if cookies are enabled in Postman
- In production, ensure HTTPS is used
- Check `sameSite` and `secure` settings match your environment

### User not created
- Check database connection
- Verify email is provided (required for new users)
- Check for validation errors in server logs

