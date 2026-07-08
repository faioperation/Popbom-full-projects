import 'package:get/get.dart';
import 'package:popbom/app/urls.dart';
import 'package:popbom/core/services/network/network_client.dart';

class FollowUnfollowAllUserController extends GetxController {
  final NetworkClient _client = Get.find<NetworkClient>();

  /// Follow / Unfollow user
  ///
  /// returns:
  ///   "follow"   → if user is now followed
  ///   "unfollow" → if user is now unfollowed
  ///   null       → if request failed
  Future<String?> toggleFollow(String targetUserId) async {
    final response = await _client.postRequest(
      Urls.followAndUnfollowUrl,
      body: {"followedUserId": targetUserId},
    );

    if (!response.isSuccess) return null;

    final status = response.responseData?["data"]?["status"];
    return status; // "follow" or "unfollow"
  }
}
