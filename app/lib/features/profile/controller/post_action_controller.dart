import 'package:get/get.dart';
import 'package:popbom/app/urls.dart';
import 'package:popbom/core/services/network/network_client.dart';

class PostActionsController extends GetxController {
  final _client = Get.find<NetworkClient>();

  Future<String?> toggleLike({
    required String postId,
    required bool isLikedNow,
  }) async {
    try {
      final res = await _client.postRequest(
        Urls.addReactionOnPost,
        body: {
          "postId": postId,
          "reaction": isLikedNow ? "heart" : "none",
        },
      );

      if (!res.isSuccess) return null;

      final data = res.responseData?['data'];
      return data?['_id'];
    } catch (_) {
      return null;
    }
  }


  Future<Map<String, dynamic>?> getReactionByPostId(String postId) async {
    try {
      final res = await _client.getRequest(Urls.getReactionByPostId(postId));

      if (!res.isSuccess) return null;

      final data = res.responseData?['data'];

      if (data is List && data.isNotEmpty) {
        return data.first;
      }

      return null;
    } catch (_) {
      return null;
    }
  }


  Future<bool> removeReaction(String reactionId) async {
    try {
      final res =
      await _client.deleteRequest(Urls.removeReactionByReactionId(reactionId));

      return res.isSuccess;
    } catch (_) {
      return false;
    }
  }


  Future<Map<String, dynamic>?> toggleSave({
    required String postId,
    required bool isCurrentlySaved,
    String? savedRecordId, // 🔥 IMPORTANT
  }) async {
    try {
      // 🔴 UNSAVE (delete by savedRecordId)
      if (isCurrentlySaved) {
        if (savedRecordId == null || savedRecordId.isEmpty) {
          print("⚠ savedRecordId missing, cannot unsave");
          return null;
        }

        final res = await _client.deleteRequest(
          Urls.deleteSavePost(savedRecordId), // ✅ USE _id
        );

        if (!res.isSuccess) return null;

        return {
          "isSaved": false,
          "savedRecordId": null,
        };
      }

      // 🟢 SAVE (create saved record using postId)
      final res = await _client.postRequest(
        Urls.savePost,
        body: {"postId": postId},
      );

      if (!res.isSuccess) return null;

      final data = res.responseData?["data"];

      return {
        "isSaved": true,
        "savedRecordId": data?["_id"], // ✅ store this
      };
    } catch (e) {
      print("❌ toggleSave error: $e");
      return null;
    }
  }



  Future<bool> createComment({
    required String postId,
    required String comment,
  }) async {
    try {
      final res = await _client.postRequest(
        Urls.createCommentOnPost,
        body: {
          "postId": postId,
          "comment": comment,
        },
      );

      print("💬 Comment API: ${res.responseData}");
      return res.isSuccess;
    } catch (e) {
      print("Comment Error: $e");
      return false;
    }
  }


  Future<bool> sharePost({
    required String postId,
    required String platform,
  }) async {
    try {
      final res = await _client.postRequest(
        Urls.sharePost,
        body: {
          "postId": postId,
          "sharingPlatform": platform, // 👈 dynamic
        },
      );

      print("📤 Share API ($platform): ${res.responseData}");
      return res.isSuccess;
    } catch (e) {
      print("Share Error: $e");
      return false;
    }
  }

}
