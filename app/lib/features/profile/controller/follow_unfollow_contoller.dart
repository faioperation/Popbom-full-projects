import 'package:get/get.dart';
import 'package:popbom/app/urls.dart';
import 'package:popbom/core/services/network/network_client.dart';
import 'package:popbom/features/common/controllers/auth_controller.dart';

class FollowUnfollowController extends GetxController {
  final NetworkClient _client = Get.find<NetworkClient>();
  AuthController get _auth => Get.find<AuthController>();

  /// following list (Rx)
  RxList<String> followingIds = <String>[].obs;
  RxList<String> followerIds = <String>[].obs;

  /// followers count
  RxInt followersCount = 0.obs;

  /// following count
  RxInt followingCount = 0.obs;
  RxBool followLoaded = false.obs;

  @override
  void onInit() {
    super.onInit();
    final savedUser = _auth.userModel;
    if (savedUser != null && savedUser.followingIds.isNotEmpty) {
      followingIds.assignAll(savedUser.followingIds);
      followingCount.value = savedUser.followingIds.length;
    }
  }
  void _persistFollowData() {
    if (_auth.userModel == null) return;

    _auth.userModel!.followingIds = followingIds.toList();
    _auth.userModel!.followingCount = followingIds.length;

    _auth.saveUserData(_auth.accessToken, _auth.userModel!);
  }

  void _saveFollowingToUserModel() {
    if (_auth.userModel == null) return;

    _auth.userModel!.followingIds = followingIds.toList();
    _auth.userModel!.followingCount = followingIds.length;

    _auth.saveUserData(_auth.accessToken, _auth.userModel!);
  }


  Future<void> refreshFollowing() async {
    try {
      // 🔹 1) Get FOLLOWING list
      final res = await _client.getRequest(
        Urls.getFollowingListUrl(_auth.userId!),
      );

      if (res.isSuccess) {
        final List items = res.responseData?["data"] ?? [];

        followingIds.value = items.map<String>((e) {
          final f = e["followedUserId"];
          if (f is Map && f["_id"] != null) return f["_id"].toString();
          return "";
        }).where((id) => id.isNotEmpty).toList();

        followingCount.value = followingIds.length;
        _saveFollowingToUserModel();
      }

      // 🔹 2) Get FOLLOWERS list
      final res2 = await _client.getRequest(
        Urls.getFollowersUrl(_auth.userId!),
      );

      if (res2.isSuccess) {
        final List items = res2.responseData?["data"] ?? [];

        followerIds.value = items.map<String>((e) {
          final u = e["followingUserId"];       // << FIXED
          if (u is Map && u["_id"] != null) return u["_id"].toString();
          return "";
        }).where((id) => id.isNotEmpty).toList();

        followersCount.value = followerIds.length;
      }

      followLoaded.value = true;
      update();
    } catch (e) {
      print("refreshFollowing ERROR: $e");
    }
    print("===== FOLLOW DEBUG =====");
    print("followingIds: ${followingIds}");
    print("followerIds: ${followerIds}");
    print("followLoaded: ${followLoaded.value}");
    print("=========================");

  }


  /// FOLLOW / UNFOLLOW
  Future<String?> toggleFollow(String targetUserId) async {
    final response = await _client.postRequest(
      Urls.followAndUnfollowUrl,
      body: {"followedUserId": targetUserId},
    );

    if (!response.isSuccess) return null;

    final status = response.responseData?["data"]?["status"];

    if (status == "follow") {
      followingIds.add(targetUserId);
    } else if (status == "unfollow") {
      followingIds.remove(targetUserId);
    }

    /// Update count
    followingCount.value = followingIds.length;

    /// ⭐ Save into user model + local storage
    _saveFollowingToUserModel();

    return status;
  }

  bool isFollowing(String id) => followingIds.contains(id);
}
