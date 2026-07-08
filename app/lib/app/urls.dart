class Urls {
  static const String _baseUrl = 'http://172.252.13.97:5000';
  static const String baseUrl = _baseUrl;
  static const String socketBase = _baseUrl;

  static const String refreshToken = '$_baseUrl/api/auth/refresh-token';

  static const String signUpUrl = '$_baseUrl/api/auth/register';
  static const String signInUrl = '$_baseUrl/api/auth/login';
  static const String forgotEmailUrl = '$_baseUrl/api/auth/forgot-password';
  static const String otpVerifyUrl = '$_baseUrl/api/auth/verify-otp';
  static const String resendOtpVerifyUrl = '$_baseUrl/api/auth/verify-otp';
  static const String resetPassUrl = '$_baseUrl/api/auth/reset-password';
  static const String appleLoginUrl = '$_baseUrl/api/auth/apple';
  static const String googleLoginUrl = '$_baseUrl/api/auth/google';

  static const String getALlUser = '$_baseUrl/api/users';

  static const String updateProfileUrl = '$_baseUrl/api/users/update-profile';
  static const String updatePhotoUrl =
      '$_baseUrl/api/users/update-profile-photo';
  static const String getMyProfileUrl = '$_baseUrl/api/users/me';
  static const String allUsersWithFollowStatusUrl =
      '$_baseUrl/api/users/alluser-with-follow-status';

  static const String followAndUnfollowUrl = '$_baseUrl/api/follow/toggle';

  static String getFollowingListUrl(String userId) {
    return "$_baseUrl/api/follow/following/$userId";
  }

  static String getFollowersUrl(String userId) {
    return "$_baseUrl/api/follow/followers/$userId";
  }

  static String getUserProfileById(String userId) {
    return "$_baseUrl/api/users/$userId";
  }

  static String getTotalReactionsByUserId(String userId) {
    return "$_baseUrl/api/post-reactions/reactions/total/$userId";
  }

  static const String reelsPostUrl = '$_baseUrl/api/posts';
  static const String getAllMusicUrl = '$_baseUrl/api/music/all';
  static const String searchMusicUrl = '$_baseUrl/api/music/search';

  static const String getMyPost = '$_baseUrl/api/posts/my-posts';
  static const String getSinglePostByPostId =
      '$_baseUrl/api/posts/68fee706a3492df83306842d';

  static String deletePost(String postId) => "$baseUrl/api/posts/$postId";

  static const String getAllTrendingPost = '$baseUrl/api/posts/trending';

  ///STORY
  static const String createStory = '$_baseUrl/api/posts';
  static const String getLoggedInUserStory = '$_baseUrl/api/stories/user';
  static const String getAllStories = '$_baseUrl/api/stories';

  static String getUserStories(String userId) =>
      '$_baseUrl/api/stories/user/$userId';

  static const String storyReaction = '$_baseUrl/api/story-reaction';
  static const String storyReply = '$_baseUrl/api/story-reply';

  static String deleteStoryReaction(String reactionId) =>
      '$_baseUrl/api/story-reaction/$reactionId';

  static String getAllStoryReactionById(String storyId) =>
      '$_baseUrl/api/story-reaction/story/$storyId';

  static String getReactionCountById(String storyId) =>
      '$_baseUrl/api/post-reactions/reactions/total/$storyId';



  ///CHALLENGE
  static const String createChallenges = '$_baseUrl/api/challenges';
  static const String getMyChallenges = '$_baseUrl/api/challenges/my';
  static const String getMyChallengesAndRank = '$_baseUrl/api/challenge-participants/my/challenges';
  static const String getAllChallenges = '$_baseUrl/api/challenges/all';
  static const String getParticipatedChallenges =
      '$_baseUrl/api/challenges/participated';
  static String getChallengesByChallengeId(String id) {
    return "$_baseUrl/api/challenges/$id";
  }
  static const String participatedAChallenge = '$_baseUrl/api/challenge-participants';
  static String getChallengesRankWhereIParticipant(String id) {
    return "$_baseUrl/api/challenge-participants/all/$id";
  }
  static const String getAllChallengeVideo = '$_baseUrl/api/challenges/videos';


  static String getUserPostsUrl(String userId) {
    return "$_baseUrl/api/posts/user-posts/$userId";
  }

  static const String addReactionOnPost = '$_baseUrl/api/post-reactions';

  static String removeReactionByReactionId(String id) {
    return "$_baseUrl/api/post-reactions/$id";
  }

  static String getReactionByPostId(String postId) {
    return "$_baseUrl/api/post-reactions/post/$postId";
  }

  static const String savePost = '$_baseUrl/api/saved-posts';

  static const String loggedInUserSavePost = '$_baseUrl/api/saved-posts/user';

  static String deleteSavePost(String savePostId) {
    return "$_baseUrl/api/saved-posts/$savePostId";
  }

  static String getReactionByUserId(String userId) {
    return "$_baseUrl/api/post-reactions/post/$userId";
  }

  static const String createCommentOnPost = '$_baseUrl/api/comments';

  static String getCommentsByPostId(String postId) =>
      "$_baseUrl/api/comments/post/$postId";

  static String deleteCommentById(String commentId) =>
      "$_baseUrl/api/comments/$commentId";

  static const String sharePost = '$_baseUrl/api/shared-posts';

  ///update password with profile
  static const String updateProfileWithPassword =
      '$_baseUrl/api/users/update-profile-password';

  static String getTaggedPostsUrl(String userId) {
    return "$_baseUrl/api/posts/tagged/$userId";
  }

  static const String getAllPost = "$_baseUrl/api/posts";
  static const String incrementWatchCount =
      "$_baseUrl/api/post-watch-count/increment";

  static String fetchPostById(String postId) {
    return "$_baseUrl/api/posts/$postId";
  }

  ///chat
  static const startChat = "$_baseUrl/api/chat/start";
  static const getAllChatList = "$_baseUrl/api/chat";
  static const sendMessage = "$_baseUrl/api/chat/send";

  static String messages(String chatId) =>
      "$_baseUrl/api/chat/$chatId/messages";

  ///gift
  static const getGift = "$_baseUrl/api/users/gift-info/all";
  static const sendGift = "$_baseUrl/api/gift";

  static String getSingleUserGiftInfo(String userId) {
    return "$_baseUrl/api/users/gift-info/$userId";
  }

  ///report
  static const createReport = "$_baseUrl/api/report";

  ///qr code
  static const shareProfileUrl = "$_baseUrl/api/share-profile";

  /// NOTIFICATION
  static String getUserNotifications(String userId) {
    return "$_baseUrl/api/notification/user/$userId";
  }


  ///recommendation
  static const getRecommendationVideo = "$_baseUrl/api/ai-recommendation/get-feed";
  static const getSteamFeed = "$_baseUrl/api/ai-recommendation/get-stem-feed";

  ///visual search
  static const visualSearchByText = "$_baseUrl/api/ai-visual-search/by-text";
  static const visualSearchByImage = "$_baseUrl/api/ai-visual-search/by-image";
  static const visualSearchByVoice = "$_baseUrl/api/ai-visual-search/by-audio";


  ///live
  static const String startLive = "$_baseUrl/api/live/start";
  static const String endLive = "$_baseUrl/api/live/end";
  static const String agoraToken = "$_baseUrl/api/live/agora/token";
  static const String allActiveLive = "$_baseUrl/api/live/active";
  static const String joinLive = "$_baseUrl/api/live/viewer/join";
  static const String leaveLive = "$_baseUrl/api/live/viewer/leave";


}
