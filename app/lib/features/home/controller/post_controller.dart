import 'package:get/get.dart';
import 'package:popbom/app/urls.dart';
import 'package:popbom/core/services/network/network_client.dart';

class PostController extends GetxController {
  final NetworkClient _client = Get.find<NetworkClient>();

  bool loading = false;
  bool loadingMore = false;

  List<dynamic> _allPosts = [];
  List<dynamic> posts = [];

  int _pageSize = 20;
  int _currentIndex = 0;

  void _setLoading(bool v) {
    loading = v;
    update();
  }

  void _setLoadingMore(bool v) {
    loadingMore = v;
    update();
  }

  void _resetPagination(List<dynamic> data) {
    _allPosts = data;
    posts = [];
    _currentIndex = 0;
    loadMore();
  }

  void loadMore() async {
    if (loadingMore) return;
    if (_currentIndex >= _allPosts.length) return;

    _setLoadingMore(true);

    // optional tiny delay (smooth UX)
    await Future.delayed(const Duration(milliseconds: 300));

    final nextItems = _allPosts.skip(_currentIndex).take(_pageSize).toList();

    posts.addAll(nextItems.map((e) => Map<String, dynamic>.from(e)).toList());
    _currentIndex += _pageSize;

    _setLoadingMore(false);
  }

  Future<void> fetchAllPosts() async {
    _setLoading(true);

    // 1. Cache
    try {
      final cacheRes = await _client.getRequest(
        Urls.getAllPost,
        fromCache: true,
      );
      if (cacheRes.isSuccess) {
        final raw = cacheRes.responseData?["data"];
        if (raw is List) _resetPagination(raw);
      }
    } catch (_) {}

    // 2. Network
    final res = await _client.getRequest(Urls.getAllPost);

    if (res.isSuccess) {
      final raw = res.responseData?["data"];
      if (raw is List) {
        _resetPagination(raw);
      }
    }

    _setLoading(false);
  }

  Future<void> fetchTrendingPosts() async {
    _setLoading(true);

    // 1. Cache
    try {
      final cacheRes = await _client.getRequest(
        Urls.getAllTrendingPost,
        fromCache: true,
      );
      if (cacheRes.isSuccess) {
        final raw = cacheRes.responseData?["data"];
        if (raw is List) _resetPagination(raw);
      }
    } catch (_) {}

    // 2. Network
    final res = await _client.getRequest(Urls.getAllTrendingPost);

    if (res.isSuccess) {
      final raw = res.responseData?["data"];
      if (raw is List) {
        _resetPagination(raw);
      }
    }

    _setLoading(false);
  }

  Future<void> fetchRecommendedPosts() async {
    _setLoading(true);

    // 1. Cache
    try {
      final cacheRes = await _client.getRequest(
        Urls.getRecommendationVideo,
        fromCache: true,
      );
      if (cacheRes.isSuccess) {
        final raw = cacheRes.responseData?["data"];
        if (raw is List) _handleRecommendedData(raw);
      }
    } catch (_) {}

    // 2. Network
    final res = await _client.getRequest(Urls.getRecommendationVideo);

    if (res.isSuccess) {
      final raw = res.responseData?["data"];

      if (raw is List) {
        _handleRecommendedData(raw);
      }
    }

    _setLoading(false);
  }

  void _handleRecommendedData(List raw) {
    /// 🔴 IMPORTANT:
    /// AI recommendation API structure != normal posts
    /// so we normalize here ONLY for recommended posts

    final normalized = raw.map((e) {
      final meta = e["metadata"] ?? {};

      return {
        "_id": e["post_id"],
        "title": e["title"] ?? meta["title"],
        "videoUrl": meta["video_url"],
        "authorId": meta["authorId"],
        "counts":
            meta["counts"] ??
            {
              "likes": 0,
              "comments": 0,
              "shares": 0,
              "saved": 0,
              "views": meta["counts"]?["watchCount"] ?? 0,
            },

        // optional flags (safe default)
        "isLiked": false,
        "isSaved": false,
      };
    }).toList();

    _resetPagination(normalized);
  }

  Future<void> fetchChallengePosts() async {
    _setLoading(true);

    // 1. Cache
    try {
      final cacheRes = await _client.getRequest(
        Urls.getAllChallengeVideo,
        fromCache: true,
      );
      if (cacheRes.isSuccess) {
        final raw = cacheRes.responseData?["data"];
        if (raw is List) _handleChallengeData(raw);
      }
    } catch (_) {}

    // 2. Network
    final res = await _client.getRequest(Urls.getAllChallengeVideo);

    if (res.isSuccess) {
      final raw = res.responseData?["data"];

      if (raw is List) {
        _handleChallengeData(raw);
      }
    }

    _setLoading(false);
  }

  void _handleChallengeData(List raw) {
    final normalized = raw.map((e) {
      final counts = e["counts"] ?? {};

      return {
        ...e,

        // 🔥 normalize counts
        "counts": {
          "likes": counts["like"] ?? 0,
          "comments": counts["comment"] ?? 0,
          "shares": counts["share"] ?? 0,
          "saved": counts["saved"] ?? 0,
          "views": counts["watchCount"] ?? 0,
        },

        // optional flags
        "isLiked": false,
        "isSaved": false,
      };
    }).toList();

    _resetPagination(normalized);
  }
}
