import 'dart:io';

import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:popbom/app/urls.dart';
import 'package:popbom/core/services/network/network_client.dart';
import 'package:popbom/features/profile/model/studio_post_model.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class StudioController extends GetxController {
  bool _inProgress = false;
  String? _errorMessage;

  bool get inProgress => _inProgress;
  String? get errorMessage => _errorMessage;

  int tab = 0; // 0 = Trending, 1 = Recommended

  final List<StudioPost> trendingPosts = [];
  final List<StudioPost> recommendedPosts = [];

  List<StudioPost> get visiblePosts =>
      tab == 0 ? trendingPosts : recommendedPosts;

  /// initial call
  @override
  void onInit() {
    super.onInit();
    getTrendingPosts();
  }

  void changeTab(int index) {
    if (tab == index) return;

    tab = index;
    update();

    if (index == 0 && trendingPosts.isEmpty) {
      getTrendingPosts();
    } else if (index == 1 && recommendedPosts.isEmpty) {
      getRecommendedPosts();
    }
  }


  Future<String> _thumbnailCachePath(String postId) async {
    final dir = await getApplicationSupportDirectory();
    return '${dir.path}/studio_thumb_$postId.png';
  }

  Future<String?> generateThumbnailOnce({
    required String postId,
    required String videoUrl,
  }) async {
    try {
      final path = await _thumbnailCachePath(postId);
      final file = File(path);

      if (await file.exists()) {
        return path; // ✅ cached
      }

      final thumb = await VideoThumbnail.thumbnailFile(
        video: videoUrl,
        thumbnailPath: path,
        imageFormat: ImageFormat.PNG,
        maxWidth: 400,
        quality: 60,
      );

      return thumb;
    } catch (e) {
      print("⚠️ Studio thumbnail error: $e");
      return null;
    }
  }


  void _generateThumbnailAsync(StudioPost post, List<StudioPost> sourceList) async {
    if (post.videoUrl.isEmpty) return;

    // already generated
    if (post.thumbnail != null) return;

    try {
      final thumb = await generateThumbnailOnce(
        postId: post.id,
        videoUrl: post.videoUrl,
      );

      if (thumb != null) {
        final index = sourceList.indexWhere((p) => p.id == post.id);
        if (index != -1) {
          sourceList[index].thumbnail = thumb;
          update();
        }
      }
    } catch (e) {
      print("⚠️ Thumbnail async failed: $e");
    }
  }



  /// 🔥 TRENDING POSTS
  Future<void> getTrendingPosts() async {
    if (_inProgress) return;

    _inProgress = true;
    _errorMessage = null;
    update();

    try {
      final response = await Get.find<NetworkClient>().getRequest(
        Urls.getAllTrendingPost, // /api/posts/trending
      );

      if (response.isSuccess &&
          response.responseData != null &&
          response.responseData!['data'] != null) {

        final List list = response.responseData!['data'];

        trendingPosts
          ..clear()
          ..addAll(list.map((e) {
            final post = StudioPost.fromTrending(e);

            _generateThumbnailAsync(post, trendingPosts);

            return post;
          }));

      }

    } catch (e) {
      _errorMessage = 'Something went wrong: $e';
    }

    _inProgress = false;
    update();
  }

  /// 🤖 RECOMMENDED POSTS
  Future<void> getRecommendedPosts() async {
    if (_inProgress) return;

    _inProgress = true;
    _errorMessage = null;
    update();

    try {
      final response = await Get.find<NetworkClient>().getRequest(
        Urls.getRecommendationVideo, // /api/ai-recommendation/get-feed
      );

      if (response.isSuccess &&
          response.responseData != null &&
          response.responseData!['data'] != null) {

        final List list = response.responseData!['data'];

        recommendedPosts
          ..clear()
          ..addAll(list.map((e) {
            final post = StudioPost.fromRecommended(e);

            _generateThumbnailAsync(post, recommendedPosts);

            return post;
          }));

      }

    } catch (e) {
      _errorMessage = 'Something went wrong: $e';
    }

    _inProgress = false;
    update();
  }
}
