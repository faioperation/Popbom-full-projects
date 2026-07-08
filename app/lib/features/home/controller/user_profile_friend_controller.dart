import 'package:get/get.dart';
import 'package:popbom/app/urls.dart';
import 'package:popbom/core/services/network/network_client.dart';
import 'package:popbom/features/common/controllers/auth_controller.dart';

class UserFollowersController extends GetxController {
  bool loading = false;
  String? error;

  List<dynamic> followers = [];
  String? currentUserId;

  final NetworkClient _client = Get.find<NetworkClient>();
  final AuthController _auth = Get.find<AuthController>();

  /// Logged-in user following list
  RxList<String> followingIds = <String>[].obs;

  @override
  void onInit() {
    super.onInit();

    /// Load saved following list from Auth user model
    if (_auth.userModel != null &&
        _auth.userModel!.followingIds.isNotEmpty) {
      followingIds.assignAll(_auth.userModel!.followingIds);
    }
  }

  /// Save following list to user model + local storage
  void _saveFollowingToUserModel() {
    if (_auth.userModel == null) return;

    _auth.userModel!.followingIds = followingIds.toList();
    _auth.userModel!.followingCount = followingIds.length;

    _auth.saveUserData(_auth.accessToken, _auth.userModel!);
  }

  /// 🔥 Load followers of a profile
  Future<void> loadFollowers(String userId) async {
    currentUserId = userId;
    loading = true;
    update();

    try {
      final res = await _client.getRequest(Urls.getFollowersUrl(userId));

      if (res.isSuccess) {
        followers = res.responseData?["data"] ?? [];
      } else {
        error = res.errorMassage ?? "Failed to load followers";
      }
    } catch (e) {
      error = e.toString();
    }

    loading = false;
    update();
  }

  /// 🔥 FOLLOW / UNFOLLOW exactly like your working controller
  Future<bool> toggleFollow(String targetUserId) async {
    try {
      final response = await _client.postRequest(
        Urls.followAndUnfollowUrl,
        body: {"followedUserId": targetUserId},
      );

      if (!response.isSuccess) return false;

      final status = response.responseData?["data"]?["status"];

      if (status == "follow") {
        followingIds.add(targetUserId);
      } else if (status == "unfollow") {
        followingIds.remove(targetUserId);

        followers.removeWhere((f) {
          final u = f["followingUserId"];
          return u != null && u["_id"] == targetUserId;
        });
      }

      _saveFollowingToUserModel();

      update();
      return true;
    } catch (e) {
      return false;
    }
  }


  bool isFollowing(String id) => followingIds.contains(id);
}
