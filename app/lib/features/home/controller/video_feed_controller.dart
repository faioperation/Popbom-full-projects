import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:popbom/app/urls.dart';
import 'package:popbom/core/services/network/network_client.dart';
import 'package:popbom/features/common/controllers/auth_controller.dart';
import 'package:popbom/features/home/models/video_item_model.dart';
import 'package:video_player/video_player.dart';


enum FeedType {
  live,
  steam,
  discover,
  following,
  your5,
}

extension FeedTypeX on FeedType {
  String get key {
    switch (this) {
      case FeedType.live:
        return "live";
      case FeedType.steam:
        return "steam";
      case FeedType.discover:
        return "discover";
      case FeedType.following:
        return "following";
      case FeedType.your5:
        return "your5";
    }
  }
}


class VideoFeedController extends GetxController {
  final NetworkClient _client = Get.find<NetworkClient>();

  RxBool loading = false.obs;
  RxnString error = RxnString();
  RxList<dynamic> videos = <dynamic>[].obs;
  RxList<VideoItem> mappedItems = <VideoItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Re-map whenever videos change
    ever(videos, (_) => _updateMappedItems());
  }

  void _updateMappedItems() {
    mappedItems.assignAll(videos.map((v) => _mapVideoItem(v, currentFeed.value)).toList());
  }

  /// Public helper for search results
  List<VideoItem> mapSearchItems(List<dynamic> list) {
    return list.map((v) => _mapVideoItem(v, null, isSearch: true)).toList();
  }

  VideoItem _mapVideoItem(dynamic v, FeedType? feedType, {bool isSearch = false}) {
    if (isSearch) {
      // 🔍 DETECT SOURCE
      final bool isHomePost = v.containsKey("authorId");
      
      if (isHomePost) {
        // 🏠 HOME FEED POST STRUCTURE
        final author = v["authorId"] ?? {};
        final userDetails = author["userDetails"] ?? {};
        final counts = v["counts"] ?? {};

        String videoUrl = v["videoUrl"]?.toString() ?? "";
        if (videoUrl.isNotEmpty && !videoUrl.startsWith("http")) {
          videoUrl = "${Urls.baseUrl}/$videoUrl";
        }
        String avatar = userDetails["photo"]?.toString() ?? "";
        if (avatar.isNotEmpty && !avatar.startsWith("http")) {
          avatar = "${Urls.baseUrl}/$avatar";
        }

        return VideoItem(
          id: v["_id"]?.toString() ?? "",
          url: videoUrl,
          userId: author["_id"]?.toString() ?? "",
          userName: "@${author["username"]?.toString() ?? "user"}",
          userFullName: userDetails["name"]?.toString() ?? author["username"]?.toString() ?? "User",
          userAvatar: avatar,
          caption: v["title"] ?? "Search Result",
          likes: counts["likes"] ?? 0,
          comments: counts["comments"] ?? 0,
          shares: counts["shares"] ?? 0,
          saves: counts["saved"] ?? 0,
          views: counts["views"] ?? counts["watchCount"] ?? 0,
          shareLink: v["_id"] != null ? "https://popbom.app/post/${v["_id"]}" : "",
           // Check if API returns these for search
           isLiked: v["isLiked"] ?? false,
        );
      } else {
        // 🔍 VISUAL SEARCH POST STRUCTURE
        final user = v["user"] ?? {};
        
        String videoUrl = v["videoUrl"]?.toString() ?? "";
        if (videoUrl.isNotEmpty && !videoUrl.startsWith("http")) {
          videoUrl = "${Urls.baseUrl}/$videoUrl";
        }
        String avatar = user["photo"]?.toString() ?? "";
        if (avatar.isNotEmpty && !avatar.startsWith("http")) {
           avatar = "${Urls.baseUrl}/$avatar";
        }

        return VideoItem(
          id: v["postId"]?.toString() ?? "",
          url: videoUrl,
          userId: user["id"]?.toString() ?? "",
          userName: "@${user["username"]?.toString() ?? "user"}",
          userFullName: user["name"]?.toString() ?? user["username"]?.toString() ?? "User",
          userAvatar: avatar,
          caption: v["title"] ?? "",
          likes: v["likes"] ?? 0,
          comments: v["comments"] ?? 0,
          shares: v["shares"] ?? 0,
          saves: v["saved"] ?? 0,
          views: v["watchCount"] ?? 0,
          shareLink: v["postId"] != null ? "https://popbom.app/post/${v["postId"]}" : "",
        );
      }
    }

    if (feedType == FeedType.live) {
         // LIVE Mapping
         // Check if it matches Screen logic: id: v["liveId"]
         // The controller previously used v["_id"]. 
         // Screen used: id: v["liveId"], liveChannel: v["channel"]...
         
         // Assuming 'v' structure from 'Urls.allActiveLive' response:
         // If "liveId" exists, use it. Else fallback.
         final id = v["liveId"] ?? v["_id"] ?? "";
         
         final author = v["authorId"] is Map ? v["authorId"] : {};
         // note: Screen used v["username"] directly sometimes?
         // Screen: userId: v["userId"], userName: v["username"]
         // Controller: author["_id"], author["username"]
         
         // Merging logic to be safe:
         final userId = v["userId"] ?? author["_id"] ?? "";
         final username = v["username"] ?? author["username"] ?? "live";
         final channel = v["channel"] ?? v["channelName"];
         
         return VideoItem(
            id: id,
            url: "",
            userId: userId,
            userName: "@$username",
            userFullName: username, // simplistic mapping from Screen
            userAvatar: "", // Screen passed empty string
            caption: "LIVE",
            likes: 0,
            comments: 0,
            shares: 0,
            saves: 0,
            views: v["viewers"] ?? 0,
            shareLink: "",
            isLive: true,
            liveChannel: channel,
            agoraToken: v["agoraToken"] ?? (v["agora"] is Map ? v["agora"]["token"] : null),
            agoraUid: v["uid"] ?? (v["agora"] is Map ? v["agora"]["uid"] : null),
         );
    } 
    
    if (feedType == FeedType.steam) {
         // STEAM / AI FEED Mapping
         final meta = (v["metadata"] is Map) ? v["metadata"] as Map<String, dynamic> : {};
         final counts = (meta["counts"] is Map) ? meta["counts"] as Map<String, dynamic> : {};
         final author = (meta["authorId"] is Map) ? meta["authorId"] as Map<String, dynamic> : {};
         final userDetails = (author["userDetails"] is Map) ? author["userDetails"] as Map<String, dynamic> : {};
         
         final postId = meta["post_id"]?.toString() ?? "";
         
         String videoUrl = meta["video_url"]?.toString() ?? "";
         if (videoUrl.isNotEmpty && !videoUrl.startsWith("http")) {
            videoUrl = "${Urls.baseUrl}/$videoUrl";
         }
         
         String avatar = userDetails["photo"]?.toString() ?? "";
         if (avatar.isNotEmpty && !avatar.startsWith("http")) {
            avatar = "${Urls.baseUrl}/$avatar";
         }
         
         final username = author["username"]?.toString().isNotEmpty == true ? author["username"].toString() : "user";
         final fullName = userDetails["name"]?.toString().isNotEmpty == true ? userDetails["name"].toString() : username;

         return VideoItem(
           id: postId,
           url: videoUrl,
           userId: author["_id"]?.toString() ?? "",
           userName: "@$username",
           userFullName: fullName,
           userAvatar: avatar,
           caption: meta["title"]?.toString() ?? "",
           likes: counts["likes"] ?? 0,
           comments: counts["comments"] ?? 0,
           shares: counts["shares"] ?? 0,
           saves: counts["saved"] ?? 0,
           views: counts["watchCount"] ?? 0,
           shareLink: postId.isNotEmpty ? "https://popbom.app/post/$postId" : "",
         );
    }
    
    // DEFAULT / NORMAL FEED
    // The Screen had robust mapping for this too (checking metadata structure first)
    // Structure: v["metadata"] ? or v direct fields?
    // Screen logic at 'else' block (lines 1140): checks v["metadata"] first!
    // Controller original logic checks v["authorId"] directly.
    // If API is consistent, 'v' in 'getAllPost' has metadata?
    // Let's use the Screen's logic which seems to handle 'metadata' nesting if present.
    
    Map<String, dynamic> meta = {};
    if (v["metadata"] is Map) {
      meta = v["metadata"] as Map<String, dynamic>;
    } else {
      // Fallback: assume 'v' itself is the object (historical controller logic)
      meta = v is Map<String, dynamic> ? v : {}; 
    }
    
    // Check if we should use 'meta' or 'v' for root fields
    // Screen logic: 'final meta = (v["metadata"] is Map) ? ...'
    // If v["metadata"] exists, use it.
    // If NOT, maybe it's the direct structure.
    
    // Safe approach: check where 'videoUrl' or 'post_id'/'_id' lives.
    String id = meta["post_id"]?.toString() ?? v["_id"]?.toString() ?? "";
    String videoUrl = meta["video_url"]?.toString() ?? v["videoUrl"]?.toString() ?? "";
    String title = meta["title"]?.toString() ?? v["title"]?.toString() ?? "";
    
    // Authors
    final authorSrc = (meta["authorId"] is Map) ? meta : v;
    final author = (authorSrc["authorId"] is Map) ? authorSrc["authorId"] : (v["authorId"] is Map ? v["authorId"] : {});
    final userDetails = (author["userDetails"] is Map) ? author["userDetails"] : {};
    
    final countsSrc = (meta["counts"] is Map) ? meta : v;
    final counts = (countsSrc["counts"] is Map) ? countsSrc["counts"] : (v["counts"] is Map ? v["counts"] : {});
    
    if (videoUrl.isNotEmpty && !videoUrl.startsWith("http")) {
       videoUrl = "${Urls.baseUrl}/$videoUrl";
    }
    
    String avatar = userDetails["photo"]?.toString() ?? "";
    if (avatar.isNotEmpty && !avatar.startsWith("http")) {
       avatar = "${Urls.baseUrl}/$avatar";
    }
    
    final username = author["username"]?.toString() ?? "user";
    final fullName = userDetails["name"]?.toString() ?? username;

    return VideoItem(
      id: id,
      url: videoUrl,
      userId: author["_id"]?.toString() ?? "",
      userName: "@$username",
      userFullName: fullName,
      userAvatar: avatar,
      caption: title,
      likes: counts["likes"] ?? 0,
      comments: counts["comments"] ?? 0,
      shares: counts["shares"] ?? 0,
      saves: counts["saved"] ?? 0,
      views: counts["watchCount"] ?? counts["views"] ?? 0,
      shareLink: id.isNotEmpty ? "https://popbom.app/post/$id" : "",
      isLiked: v["isLiked"] ?? false,
    );
  }

  RxInt currentIndex = 0.obs;
  Rx<FeedType> currentFeed = FeedType.your5.obs;

// tab wise cache
  final Map<FeedType, List<dynamic>> _feedCache = {};

  String _feedUrl(FeedType feed) {
    switch (feed) {
      case FeedType.your5:
      case FeedType.discover:
        return Urls.getRecommendationVideo;

      case FeedType.steam:
        return Urls.getSteamFeed;

      case FeedType.following:
        return Urls.getAllPost;

      case FeedType.live:
        return "";
    }
  }


  Future<void> loadActiveLives() async {
    final token = Get.find<AuthController>().accessToken;
    if (token == null || token.isEmpty) return;

    loading.value = true;
    error.value = null;

    final res = await _client.getRequest(Urls.allActiveLive);

    if (!res.isSuccess) {
      error.value = res.errorMassage ?? "Failed to load live streams";
      loading.value = false;
      return;
    }


    final list = res.responseData?["data"];
    if (list is List) {
      videos.assignAll(list);
    } else {
      videos.clear();
    }

    loading.value = false;
  }


  Future<void> loadVideosByFeed(FeedType feed) async {
    final token = Get.find<AuthController>().accessToken;
    if (token == null || token.isEmpty) return;

    // currentFeed.value = feed;

    // cache
    if (_feedCache.containsKey(feed)) {
      videos.assignAll(_feedCache[feed]!);
      return;
    }

    loading.value = true;
    error.value = null;

    final res = await _client.getRequest(_feedUrl(feed));

    if (!res.isSuccess) {
      error.value = res.errorMassage ?? "Failed to load videos";
      loading.value = false;
      return;
    }

    final list = res.responseData?["data"];

    if (list is List) {
      videos.assignAll(list);
      _feedCache[feed] = List.from(list);
    } else {
      videos.clear();
    }

    loading.value = false;

  }

  void changeFeed(FeedType feed) {
    if (currentFeed.value == feed) return;

    currentFeed.value = feed;
    // Don't clear cache immediately to allow fast back-and-forth toggling
    
    if (feed == FeedType.live) {
      loadActiveLives();
    } else {
      loadVideosByFeed(feed);
    }
  }



  void setVideosFromSearch(List<dynamic> searchResults) {
    videos.assignAll(
      searchResults.map((e) {
        final meta = e["metadata"];
        return {
          "_id": meta["post_id"],
          "videoUrl": meta["video_url"],
          "title": meta["category"] ?? "",
          "counts": {
            "likes": meta["likes"] ?? 0,
            "comments": 0,
            "shares": meta["shares"] ?? 0,
            "saved": meta["saves"] ?? 0,
            "watchCount": meta["views"] ?? 0,
          },
          "authorId": {
            "_id": meta["author_id"],
            "userDetails": {
              "username": "user",
              "name": "User",
              "photo": "",
            },
          },
        };
      }).toList(),
    );
  }


  Future<void> loadVideos() async {
    final token = Get.find<AuthController>().accessToken;

    if (token == null || token.isEmpty) {
      debugPrint("⛔ No token, skipping loadVideos");
      return;
    }
    loading.value = true;
    error.value = null;

    final NetworkResponse res =
    await _client.getRequest(Urls.getAllPost);

    if (!res.isSuccess) {
      error.value = res.errorMassage ?? "Failed to load videos";
      loading.value = false;
      return;
    }

    final body = res.responseData;
    final list = body?["data"];

    if (list is List) {
      videos.assignAll(list);
    } else {
      videos.clear();
    }

    loading.value = false;
  }

  // 👇 VIEW COUNT THROTTLING
  final Set<String> _trackedViews = {};

  Future<int?> increaseView(String postId) async {
    if (postId.isEmpty || _trackedViews.contains(postId)) return null;
    
    // Optimistically mark as tracked to avoid concurrent calls
    _trackedViews.add(postId);
    
    try {
      final res = await _client.postRequest(
        Urls.incrementWatchCount,
        body: {
          "postId": postId,
        },
      );

      if (!res.isSuccess) return null;

      final updated = res.responseData?["data"];
      if (updated != null && updated["watchCount"] != null) {
        return updated["watchCount"];
      }
    } catch (_) {}

    return null;
  }

  Future<VideoPlayerController> createCachedController(String url) async {
    try {
      final file = await DefaultCacheManager().getSingleFile(url);
      return VideoPlayerController.file(file);
    } catch (_) {
      return VideoPlayerController.networkUrl(Uri.parse(url));
    }
  }

  void onVideoChanged(int index) {
    if (index < 0 || index >= videos.length) return;

    currentIndex.value = index;

    final video = videos[index];
    final videoId = video["_id"] ?? "";

    if (videoId.isNotEmpty) {
      increaseView(videoId);
    }
  }
}
