import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:popbom/app/urls.dart';
import 'package:popbom/core/services/network/network_client.dart';
import 'package:popbom/features/common/models/user_model.dart';
import 'package:popbom/features/common/controllers/auth_controller.dart';

class ReelsUploadController extends GetxController {
  final RxBool isUploading = false.obs;
  final RxBool isMusicLoading = false.obs;
  final RxList<Map<String, dynamic>> allMusic = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> searchMusic = <Map<String, dynamic>>[].obs;
  final RxList<String> taggedUserIds = <String>[].obs;
  final RxList<UserModel> taggedUsersDetails = <UserModel>[].obs;

  final RxMap<String, Map<String, dynamic>> usersCache =
      <String, Map<String, dynamic>>{}.obs;

  String getLoggedInUserId() {
    try {
      final auth = Get.find<AuthController>();
      if (auth.userModel?.id != null && auth.userModel!.id!.isNotEmpty) {
        return auth.userModel!.id!;
      }

      if (auth.userId != null && auth.userId!.isNotEmpty) {
        return auth.userId!;
      }

      return "";
    } catch (_) {
      return "";
    }
  }

  Future<void> loadUsersCacheOnce() async {
    if (usersCache.isNotEmpty) return;

    try {
      final client = Get.find<NetworkClient>();
      final resp = await client.getRequest(Urls.allUsersWithFollowStatusUrl);

      if (!resp.isSuccess) return;

      final List raw = resp.responseData?["data"] ?? [];

      for (var u in raw) {
        String id = (u["_id"] ?? u["id"] ?? u["userId"] ?? "").toString();
        if (id.isEmpty) continue;

        usersCache[id] = Map<String, dynamic>.from(u);
      }

      updateTaggedUsers(taggedUserIds.toList());
    } catch (e) {
      print("User Cache Error: $e");
    }
  }

  void updateTaggedUsers(List<String> list) {
    taggedUserIds.value = list;

    taggedUsersDetails.value = list.map((id) {
      final u = usersCache[id];

      if (u == null) {
        return UserModel(id: id);
      }

      return UserModel(
        id: id,
        username: u["username"]?.toString(),
        name: (u["name"] ?? u["details"]?["name"])?.toString(),
        photo: (u["photo"] ?? u["details"]?["photo"])?.toString(),
      );
    }).toList();
  }

  Future<void> fetchAllMusic() async {
    try {
      isMusicLoading.value = true;

      final client = Get.find<NetworkClient>();
      final res = await client.getRequest(Urls.getAllMusicUrl);

      if (res.isSuccess && res.responseData != null) {
        allMusic.value = List<Map<String, dynamic>>.from(
          res.responseData!["data"] ?? [],
        );
        searchMusic.value = allMusic;
      }
    } catch (e) {
      print("Fetch all music error: $e");
    } finally {
      isMusicLoading.value = false;
    }
  }

  Future<void> searchMusicByName(String query) async {
    if (query.trim().isEmpty) {
      searchMusic.value = allMusic;
      return;
    }

    try {
      isMusicLoading.value = true;

      final url = "${Urls.searchMusicUrl}?q=$query";
      final client = Get.find<NetworkClient>();
      final res = await client.getRequest(url);

      if (res.isSuccess && res.responseData != null) {
        searchMusic.value = List<Map<String, dynamic>>.from(
          res.responseData!["data"] ?? [],
        );
      }
    } catch (e) {
      print("Search music error: $e");
    } finally {
      isMusicLoading.value = false;
    }
  }

  Future<bool> uploadReel({
    required File videoFile,
    required String caption,
    required String music,
    required String audience,
    String? challengeId,
  }) async {
    try {
      isUploading.value = true;

      final authorId = getLoggedInUserId();
      if (authorId.isEmpty) {
        Get.snackbar("Auth Error", "User not logged in");
        return false;
      }

      final bool isChallengePost =
          challengeId != null && challengeId.isNotEmpty;

      final Map<String, String> fields = {
        "title": caption,
        "body": caption,
        "audience": audience.toLowerCase(),
        "status": "active",
        "authorId": authorId,
        "postType": isChallengePost ? "challenges" : "reels",
        "tagPeople": jsonEncode(taggedUserIds),
      };

      if (music.trim().isNotEmpty) {
        fields["musicUrl"] = music;
      }

      if (isChallengePost) {
        fields["challengeId"] = challengeId!;
      }

      final response = await Get.find<NetworkClient>().multipartRequest(
        Urls.reelsPostUrl,
        method: "POST",
        fields: fields,
        files: {"video": videoFile},
      );

      if (response.isSuccess) {

        if (isChallengePost) {
          await Get.find<NetworkClient>().postRequest(
            Urls.participatedAChallenge,
            body: {
              "challengeId": challengeId,
              "userId": authorId,
              "postId": response.responseData?["data"]?["post"]?["_id"],
            },
          );
        }

        Get.snackbar("Success", "Post uploaded successfully");
        return true;
      } else {
        Get.snackbar("Error", response.errorMassage ?? "Upload failed");
        return false;
      }
    } catch (e) {
      Get.snackbar("Exception", e.toString());
      return false;
    } finally {
      isUploading.value = false;
    }
  }

}
