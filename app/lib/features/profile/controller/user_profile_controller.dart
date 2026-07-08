import 'package:get/get.dart';
import 'package:popbom/app/urls.dart';
import 'package:popbom/core/services/network/network_client.dart';
import 'package:popbom/features/common/models/user_model.dart';
import 'package:popbom/features/profile/controller/follow_unfollow_contoller.dart';

class UserProfileController extends GetxController {
  final String userId;
  UserProfileController({required this.userId});

  bool isLoading = false;
  String? errorMessage;

  UserModel? user;        // Profile user data
  bool isFollowing = false;

  final FollowUnfollowController followController =
  Get.find<FollowUnfollowController>();

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  /// ===============================
  /// LOAD USER USING FOLLOW STATUS API
  /// ===============================
  Future<void> loadUserData() async {
    isLoading = true;
    update();

    final response =
    await Get.find<NetworkClient>().getRequest(Urls.allUsersWithFollowStatusUrl);

    if (!response.isSuccess) {
      errorMessage = "Failed to load user";
      isLoading = false;
      update();
      return;
    }

    final List data = response.responseData?["data"] ?? [];

    final item = data.firstWhere(
          (x) => x["userId"].toString() == userId,
      orElse: () => null,
    );

    if (item == null) {
      errorMessage = "User not found";
    } else {
      user = UserModel(
        id: item["userId"],
        username: item["username"],
        name: item["name"],
        photo: item["photo"],
        isFollowing: item["isFollowing"] ?? false,
      );

      isFollowing = user!.isFollowing;
    }

    isLoading = false;
    update();
  }

  /// ===============================
  /// FOLLOW / UNFOLLOW
  /// ===============================
  Future<void> toggleFollow() async {
    final status = await followController.toggleFollow(userId);

    if (status == null) return; // failed

    isFollowing = status == "follow";
    user?.isFollowing = isFollowing;

    update();
  }
}
