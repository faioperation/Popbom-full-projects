import 'dart:io';

import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:popbom/app/urls.dart';
import 'package:popbom/core/services/network/network_client.dart';
import 'package:popbom/features/common/models/user_post_model.dart';

class UserPostsController extends GetxController {
  final NetworkClient _client = Get.find<NetworkClient>();

  @override
  void onInit() {
    super.onInit();
    cleanOldThumbnails();
  }

  /// Loading state
  final RxBool loadingPosts = false.obs;
  final RxBool loadingTagged = false.obs;

  /// Data
  final RxList<UserPostModel> userPosts = <UserPostModel>[].obs;
  final RxList<UserPostModel> taggedPosts = <UserPostModel>[].obs;

  List<UserPostModel> _previousPosts = [];

  Future<void> loadUserPosts(String userId) async {
    loadingPosts.value = true;

    try {
      final res = await _client.getRequest(Urls.getUserPostsUrl(userId));

      if (!res.isSuccess) {
        userPosts.clear();
        return;
      }

      final List raw = res.responseData?["data"] ?? [];
      _previousPosts = List<UserPostModel>.from(userPosts);
      userPosts.assignAll(await _processPosts(raw));
    } catch (_) {
      userPosts.clear();
    } finally {
      loadingPosts.value = false;
    }
  }


  Future<void> loadTaggedPosts(String userId) async {
    loadingTagged.value = true;

    try {
      final res = await _client.getRequest(Urls.getTaggedPostsUrl(userId));

      if (!res.isSuccess) {
        taggedPosts.clear();
        return;
      }

      final List raw = res.responseData?["data"] ?? [];
      _previousPosts = List<UserPostModel>.from(taggedPosts);
      taggedPosts.assignAll(await _processPosts(raw));
    } catch (_) {
      taggedPosts.clear();
    } finally {
      loadingTagged.value = false;
    }
  }

  UserPostModel? _findExisting(String id) {
    return _previousPosts.firstWhereOrNull((e) => e.id == id);
  }


  Future<List<UserPostModel>> _processPosts(List items) async {
    List<UserPostModel> list = [];

    for (var e in items) {
      final incoming = UserPostModel.fromJson(e);
      final existing = _findExisting(incoming.id);

      if (existing != null) {
        incoming.isLiked = existing.isLiked;
        incoming.reactionId = existing.reactionId;
        incoming.isSaved = existing.isSaved;
        incoming.likeCount = existing.likeCount;

      }

      if (incoming.imageUrl != null && incoming.imageUrl!.isNotEmpty) {
        incoming.imageUrl = _normalizeUrl(incoming.imageUrl!);
      }

      if (incoming.videoUrl != null && incoming.videoUrl!.isNotEmpty) {
        incoming.thumbnail = null;
      }

      list.add(incoming);
    }

    return list;
  }



  void generateThumbnailsInBackground() async {
    for (final p in [...userPosts, ...taggedPosts]) {
      if (p.thumbnail == null && p.videoUrl?.isNotEmpty == true) {
        try {
          final t = await generateThumbnailOnce(
            postId: p.id,
            videoUrl: p.videoUrl!,
          );
          p.thumbnail = t;
          userPosts.refresh();
          taggedPosts.refresh();
        } catch (_) {}
      }
    }
  }


  Future<String> _thumbnailCachePath(String postId) async {
    final dir = await getApplicationSupportDirectory();
    return '${dir.path}/thumb_$postId.png';
  }

  Future<String?> generateThumbnailOnce({
    required String postId,
    required String videoUrl,
  }) async {
    final path = await _thumbnailCachePath(postId);
    final file = File(path);

    if (await file.exists()) return path;

    return await VideoThumbnail.thumbnailFile(
      video: videoUrl,
      thumbnailPath: path,
      imageFormat: ImageFormat.PNG,
      maxWidth: 400,
      quality: 60,
    );
  }


  Future<void> cleanOldThumbnails({int days = 7}) async {
    final dir = await getApplicationSupportDirectory();
    final files = await dir.list().toList();
    final now = DateTime.now();

    for (final f in files) {
      if (f is File && f.path.contains('thumb_')) {
        final stat = await f.stat();
        if (now.difference(stat.modified).inDays > days) {
          await f.delete();
        }
      }
    }
  }



  RxInt totalReactions = 0.obs;

  Future<void> fetchTotalReactions(String userId) async {
    final res = await Get.find<NetworkClient>()
        .getRequest(Urls.getTotalReactionsByUserId(userId));

    if (res.isSuccess) {
      final data = res.responseData?['data'];
      totalReactions.value = data?['totalReactions'] ?? 0;
    } else {
      totalReactions.value = 0;
    }

    update();
  }

  Future<int?> incrementWatchCount(String postId) async {
    try {
      final res = await _client.postRequest(
        Urls.incrementWatchCount,
        body: {"postId": postId},
      );

      if (!res.isSuccess) return null;

      return res.responseData?["data"]?["watchCount"];
    } catch (_) {
      return null;
    }
  }


  String _normalizeUrl(String url) {
    if (url.startsWith("http")) return url;

    return "${Urls.baseUrl}/$url"
        .replaceAll("//", "/")
        .replaceFirst("https:/", "https://")
        .replaceFirst("http:/", "http://");
  }
}
