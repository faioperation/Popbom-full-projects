import 'package:get/get.dart';
import 'package:popbom/core/services/network/network_client.dart';
import 'package:popbom/features/auth/controller/forgot_password_controller.dart';
import 'package:popbom/features/auth/controller/forgot_password_verify_controller.dart';
import 'package:popbom/features/auth/controller/reset_password_controller.dart';
import 'package:popbom/features/auth/controller/sign_in_controller.dart';
import 'package:popbom/features/auth/controller/sign_up_controller.dart';
import 'package:popbom/features/auth/ui/screen/sign_in_screen.dart';
import 'package:popbom/features/challenge/controller/challenge_details_controller.dart';
import 'package:popbom/features/challenge/controller/challenge_list_controller.dart';
import 'package:popbom/features/challenge/controller/feed_challenge_controller.dart';
import 'package:popbom/features/chat/controller/chat_controller.dart';
import 'package:popbom/features/chat/controller/chat_list_controller.dart';
import 'package:popbom/features/common/controllers/auth_controller.dart';
import 'package:popbom/features/common/controllers/reels_upload_controller.dart';
import 'package:popbom/features/common/controllers/user_profile_controller.dart';
import 'package:popbom/features/challenge/controller/challenge_create_controller.dart';
import 'package:popbom/features/home/controller/post_controller.dart';
import 'package:popbom/features/home/controller/story_controller.dart';
import 'package:popbom/features/home/controller/story_create_controller.dart';
import 'package:popbom/features/home/controller/story_reaction_and_comment_controller.dart';
import 'package:popbom/features/home/controller/video_feed_controller.dart';
import 'package:popbom/features/home/controller/visual_search_controller.dart';
import 'package:popbom/features/profile/controller/all_user_controller.dart';
import 'package:popbom/features/profile/controller/edit_profile_controller.dart';
import 'package:popbom/features/profile/controller/follow_unfollow_contoller.dart';
import 'package:popbom/features/profile/controller/post_action_controller.dart';
import 'package:popbom/features/profile/controller/profile_controller.dart';
import 'package:popbom/features/profile/controller/studio_controller.dart';
import 'package:popbom/features/profile/controller/update_photo_controller.dart';
import 'package:popbom/features/qrcode/controller/share_profile_controller.dart';

class ControllerBinder extends Bindings {
  @override
  void dependencies() {
    // 💡 Global controllers (Permanent/Needed everywhere)
    Get.put(AuthController(), permanent: true);
    Get.put(
      NetworkClient(
        onUnAuthorize: _onUnAuthorize,
        commonHeaders: () => _commonHeaders(),
      ),
      permanent: true,
    );

    // 💡 Auth/Setup flow (Standard lifecycle)
    Get.lazyPut(() => SignUpController());
    Get.lazyPut(() => SignInController());
    Get.lazyPut(() => ForgotPasswordController());
    Get.lazyPut(() => ForgotPasswordVerifyController());
    Get.lazyPut(() => ResetPasswordController());
    Get.lazyPut(() => EditProfileController());
    Get.lazyPut(() => UpdatePhotoController());

    // 💡 Utility controllers (Available when needed, disposed when not)
    Get.lazyPut(() => FollowUnfollowController(), fenix: true);
    Get.lazyPut(() => PostActionsController(), fenix: true);
    Get.lazyPut(() => FollowUnfollowAllUserController(), fenix: true);
    Get.lazyPut(() => ShareProfileController(), fenix: true);

    // 💡 Feature main controllers
    // Lazy loaded with fenix: true to revive them when needed (tab switch)
    Get.lazyPut(() => ProfileController(), fenix: true);
    Get.lazyPut(() => PostController(), fenix: true);
    Get.lazyPut(() => StoryController(), fenix: true);
    Get.lazyPut(() => FeedChallengeController(), fenix: true);
    
    // 💡 Heavy / Session-based controllers (Lazy Loaded)
    Get.lazyPut(() => ReelsUploadController());
    Get.lazyPut(() => StoryCreateController());
    Get.lazyPut(() => ChallengeCreateController());
    Get.lazyPut(() => ChallengeListController());
    Get.lazyPut(() => ChallengeDetailsController());
    Get.lazyPut(() => UserPostsController());
    Get.lazyPut(() => VideoFeedController());
    Get.lazyPut(() => ChatController());
    Get.lazyPut(() => ChatListController());
    Get.lazyPut(() => StoryReactionController());
    Get.lazyPut(() => VisualSearchController());
    Get.lazyPut(() => StudioController());
  }

  void _onUnAuthorize() async {
    await Get.find<AuthController>().clearUserData();
    Get.offAll(() => SignInScreen());
  }

  Map<String, String> _commonHeaders() {
    final auth = Get.find<AuthController>();
    final token = auth.accessToken ?? "";

    return {
      "Content-Type": "application/json",
      if (token.isNotEmpty) "Authorization": "Bearer $token",
    };
  }
}
