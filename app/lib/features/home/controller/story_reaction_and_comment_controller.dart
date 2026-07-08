import 'package:get/get.dart';
import 'package:popbom/core/services/network/network_client.dart';
import 'package:popbom/app/urls.dart';

class StoryReactionController extends GetxController {
  final NetworkClient _client = Get.find<NetworkClient>();

  final RxBool loading = false.obs;

  /// current opened story
  String _currentStoryId = "";

  /// reactions of current story
  final RxList<Map<String, dynamic>> reactions = <Map<String, dynamic>>[].obs;

  /// my reaction id for current story
  String? _myReactionId;

  /// like flag
  final RxBool likedByMe = false.obs;

  // ================================
  // INIT STORY (VERY IMPORTANT)
  // ================================
  Future<void> loadStory(String storyId, String myUserId) async {
    if (storyId.isEmpty) return;
    if (_currentStoryId == storyId) return;

    _currentStoryId = storyId;

    reactions.clear();
    likedByMe.value = false;
    _myReactionId = null;

    loading.value = true;

    final res = await _client.getRequest(
      Urls.getAllStoryReactionById(storyId),
    );

    if (res.isSuccess) {
      final List list = res.responseData?['data'] ?? [];

      for (final r in list) {
        final map = Map<String, dynamic>.from(r);
        reactions.add(map);

        if (map['reaction'] == 'like' &&
            map['userId']?['_id'] == myUserId) {
          likedByMe.value = true;
          _myReactionId = map['_id'];
        }
      }
    }

    loading.value = false;
  }

  // ================================
  // TOGGLE LIKE (PER STORY)
  // ================================
  Future<void> toggleLike({
    required String storyId,
    required String myUserId,
  }) async {
    if (storyId.isEmpty) return;
    if (_currentStoryId != storyId) {
      await loadStory(storyId, myUserId);
    }

    // optimistic UI
    likedByMe.toggle();

    if (likedByMe.value) {
      final res = await _client.postRequest(
        Urls.storyReaction,
        body: {
          "storyId": storyId,
          "reaction": "like",
        },
      );

      if (res.isSuccess) {
        _myReactionId = res.responseData?['data']?['_id'];
      } else {
        likedByMe.value = false;
      }
    } else {
      if (_myReactionId == null) return;

      final res = await _client.deleteRequest(
        Urls.deleteStoryReaction(_myReactionId!),
      );

      if (!res.isSuccess) {
        likedByMe.value = true;
      } else {
        _myReactionId = null;
      }
    }
  }

  // ================================
  // SEND REPLY (FIRE & FORGET)
  // ================================
  Future<bool> sendReply({
    required String storyId,
    required String message,
    required String myUserId,
  }) async {
    if (storyId.isEmpty || message.trim().isEmpty) return false;

    final res = await _client.postRequest(
      Urls.storyReply,
      body: {
        "storyId": storyId,
        "authorUserId": myUserId,
        "replyMessage": message.trim(),
      },
    );

    return res.isSuccess;
  }
}
