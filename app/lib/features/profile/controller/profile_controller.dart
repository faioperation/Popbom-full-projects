import 'dart:io';
import 'dart:math';

import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:popbom/app/urls.dart';
import 'package:popbom/core/services/network/network_client.dart';
import 'package:popbom/features/common/models/my_post_model.dart';
import 'package:popbom/features/common/models/user_model.dart';
import 'package:popbom/features/common/controllers/auth_controller.dart';
import 'package:popbom/features/gift/controller/gift_controller.dart';
import 'follow_unfollow_contoller.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class ProfileController extends GetxController {
  bool isLoading = false;
  bool profileLoaded = false;
  UserModel? user;
  List<MyPostModel> _previousPosts = [];

  Future<void> loadProfileOnce() async {
    if (profileLoaded) return;

    await cleanOldThumbnails();
    isLoading = true;
    update();

    await fetchMyProfile();
    if (user == null) {
      isLoading = false;
      update();
      return;
    }

    final userId = user!.id!;
    final giftC = Get.find<GiftController>();
    await Future.wait([
      fetchTotalReactions(userId),
      fetchMyPosts(),
      fetchTaggedPosts(userId),
      fetchSavedPosts(),
      giftC.loadGiftCounts(userId),
    ]);

    profileLoaded = true;
    isLoading = false;
    update();
  }

  void syncLike({
    required String postId,
    required bool isLiked,
    required int delta,
    String? reactionId,
  }) {
    void update(List<MyPostModel> list) {
      final i = list.indexWhere((p) => p.id == postId);
      if (i != -1) {
        list[i].isLiked = isLiked;
        list[i].reactionId = reactionId;
        list[i].likeCount = max(0, (list[i].likeCount ?? 0) + delta);
      }
    }

    update(myPosts);
    update(taggedPosts);
    update(savedPosts);

    myPosts.refresh();
    taggedPosts.refresh();
    savedPosts.refresh();
  }

  void syncSave({
    required String postId,
    required bool isSaved,
    String? savedRecordId,
  }) {
    void update(List<MyPostModel> list) {
      final i = list.indexWhere((p) => p.id == postId);
      if (i != -1) {
        list[i].isSaved = isSaved;
        list[i].savedRecordId = savedRecordId;
      }
    }

    update(myPosts);
    update(taggedPosts);
    update(savedPosts);

    myPosts.refresh();
    taggedPosts.refresh();
    savedPosts.refresh();
  }

  Future<void> fetchMyProfile() async {
    isLoading = true;
    update();

    final NetworkResponse response =
    await Get.find<NetworkClient>().getRequest(Urls.getMyProfileUrl);

    if (response.isSuccess) {
      final data = response.responseData;
      final userData = data?['data'];

      user = UserModel.fromJson(userData);

      final followCtrl = Get.find<FollowUnfollowController>();
      if (followCtrl.followingIds.isNotEmpty) {
        user!.followingIds = followCtrl.followingIds.toList();
        user!.followingCount = followCtrl.followingIds.length;
      }

      await Get.find<AuthController>().saveUserData(
        Get.find<AuthController>().accessToken ?? "",
        user!,
      );
    }

    isLoading = false;
    update();
  }

  RxList<MyPostModel> myPosts = <MyPostModel>[].obs;

  Future<void> fetchMyPosts() async {
    print("📱 Fetching my posts...");

    final res = await Get.find<NetworkClient>().getRequest(Urls.getMyPost);

    if (!res.isSuccess) {
      print("❌ Failed to fetch posts: ${res.errorMassage}");
      return;
    }

    final List data = res.responseData?['data'] ?? [];
    print("✅ Received ${data.length} posts from API");

    if (data.isEmpty) {
      myPosts.clear();
      myPosts.refresh();
      update();
      return;
    }

    // ⭐ SNAPSHOT BEFORE OVERWRITE
    _previousPosts = List<MyPostModel>.from(myPosts);

    // Process posts WITHOUT awaiting thumbnail generation
    final List<MyPostModel> newPosts = [];

    for (final e in data) {
      try {
        final incoming = MyPostModel(
          id: e['_id'],
          title: e['title'] ?? "",
          videoUrl: e['videoUrl'] ?? "",
          isLiked: (e['counts']?['likes'] ?? 0) > 0,
          isSaved: (e['counts']?['saved'] ?? 0) > 0,
          likeCount: e['counts']?['likes'] ?? 0,
          commentCount: e['counts']?['comments'] ?? 0,
          watchCount: e['counts']?['watchCount'] ?? 0,
        );

        // Restore previous state if exists
        final old = _previousPosts.firstWhereOrNull((p) => p.id == incoming.id);
        if (old != null) {
          incoming.isLiked = old.isLiked;
          incoming.reactionId = old.reactionId;
          incoming.isSaved = old.isSaved;
          incoming.likeCount = old.likeCount;
          incoming.thumbnail = old.thumbnail; // Preserve existing thumbnail
        }

        // Fix video URL
        if (incoming.videoUrl != null && incoming.videoUrl!.isNotEmpty) {
          if (!incoming.videoUrl!.startsWith("http")) {
            incoming.videoUrl = "${Urls.baseUrl}/${incoming.videoUrl!}";
          }

          // Generate thumbnail asynchronously (don't await)
          if (incoming.thumbnail == null) {
            _generateThumbnailAsync(incoming);
          }
        } else if (e['imageUrl'] != null) {
          // Handle image posts
          String imgUrl = e['imageUrl'];
          if (!imgUrl.startsWith("http")) {
            imgUrl = "${Urls.baseUrl}/$imgUrl";
          }
          incoming.thumbnail = imgUrl;
        }

        newPosts.add(incoming);
      } catch (e) {
        print("⚠️ Error processing post: $e");
      }
    }

    myPosts.value = newPosts;
    myPosts.refresh();
    update();

    print("✅ Updated myPosts with ${myPosts.length} posts");
  }

  // Generate thumbnails in background
  void _generateThumbnailAsync(MyPostModel post) async {
    if (post.videoUrl == null || post.videoUrl!.isEmpty) return;

    try {
      final thumb = await generateThumbnailOnce(
        postId: post.id,
        videoUrl: post.videoUrl!,
      );

      if (thumb != null) {
        final index = myPosts.indexWhere((p) => p.id == post.id);
        if (index != -1) {
          myPosts[index].thumbnail = thumb;
          myPosts.refresh();
        }
      }
    } catch (e) {
      print("⚠️ Thumbnail generation failed for ${post.id}: $e");
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
    try {
      final path = await _thumbnailCachePath(postId);
      final file = File(path);

      if (await file.exists()) {
        return path;
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
      print("⚠️ Thumbnail error: $e");
      return null;
    }
  }

  Future<void> cleanOldThumbnails({int maxDays = 7}) async {
    final dir = await getApplicationSupportDirectory();
    final files = dir.listSync().toList();
    final now = DateTime.now();

    for (final f in files) {
      if (f is File && f.path.contains('thumb_')) {
        final stat = await f.stat();
        final age = now.difference(stat.modified);

        if (age.inDays >= maxDays) {
          try {
            await f.delete();
          } catch (_) {}
        }
      }
    }
  }

  RxList<MyPostModel> taggedPosts = <MyPostModel>[].obs;

  Future<void> fetchTaggedPosts(String userId) async {
    print("🏷️ Fetching tagged posts...");

    final res = await Get.find<NetworkClient>()
        .getRequest(Urls.getTaggedPostsUrl(userId));

    if (!res.isSuccess) {
      print("❌ Failed to fetch tagged posts");
      return;
    }

    final List posts = res.responseData?['data'] ?? [];
    print("✅ Received ${posts.length} tagged posts");

    if (posts.isEmpty) {
      taggedPosts.clear();
      taggedPosts.refresh();
      update();
      return;
    }

    final List<MyPostModel> newPosts = [];

    for (final e in posts) {
      try {
        final m = MyPostModel.fromJson(e);

        // Fix author photo URL
        if (m.author?.photo != null && m.author!.photo!.isNotEmpty) {
          if (!m.author!.photo!.startsWith("http")) {
            m.author!.photo = "${Urls.baseUrl}/${m.author!.photo}";
          }
        }

        // Fix username
        if ((m.author?.username ?? "").isEmpty &&
            (m.author?.name ?? "").isNotEmpty) {
          m.author!.username = m.author!.name!;
        }

        // Fix image URL
        if (m.imageUrl != null && m.imageUrl!.isNotEmpty) {
          if (!m.imageUrl!.startsWith("http")) {
            m.imageUrl = "${Urls.baseUrl}/${m.imageUrl!}";
          }
        }

        // Fix video URL
        if (m.videoUrl != null && m.videoUrl!.isNotEmpty) {
          if (!m.videoUrl!.startsWith("http")) {
            m.videoUrl = "${Urls.baseUrl}/${m.videoUrl!}";
          }

          // Set thumbnail to image or generate later
          m.thumbnail = m.imageUrl;
          _generateThumbnailAsyncTagged(m);
        } else {
          m.thumbnail = m.imageUrl;
        }

        newPosts.add(m);
      } catch (e) {
        print("⚠️ Error processing tagged post: $e");
      }
    }

    taggedPosts.value = newPosts;
    taggedPosts.refresh();
    update();

    print("✅ Updated taggedPosts with ${taggedPosts.length} posts");
  }

  void _generateThumbnailAsyncTagged(MyPostModel post) async {
    if (post.videoUrl == null || post.videoUrl!.isEmpty) return;

    try {
      final thumb = await generateThumbnailOnce(
        postId: post.id,
        videoUrl: post.videoUrl!,
      );

      if (thumb != null) {
        final index = taggedPosts.indexWhere((p) => p.id == post.id);
        if (index != -1) {
          taggedPosts[index].thumbnail = thumb;
          taggedPosts.refresh();
        }
      }
    } catch (e) {
      print("⚠️ Thumbnail generation failed: $e");
    }
  }

  RxList<MyPostModel> savedPosts = <MyPostModel>[].obs;

  Future<void> fetchSavedPosts() async {
    print("💾 Fetching saved posts...");

    final res = await Get.find<NetworkClient>()
        .getRequest(Urls.loggedInUserSavePost);

    if (!res.isSuccess) {
      print("❌ Failed to fetch saved posts");
      savedPosts.clear();
      update();
      return;
    }

    final List items = res.responseData?['data'] ?? [];
    print("✅ Received ${items.length} saved posts");

    if (items.isEmpty) {
      savedPosts.clear();
      savedPosts.refresh();
      update();
      return;
    }

    final likedPostIds = {
      ...myPosts.where((p) => p.isLiked).map((p) => p.id),
      ...taggedPosts.where((p) => p.isLiked).map((p) => p.id),
    };

    final List<MyPostModel> newPosts = [];

    for (final e in items) {
      try {
        if (e['postId'] == null) continue;

        final post = Map<String, dynamic>.from(e['postId']);
        final author = Map<String, dynamic>.from(e['authorId'] ?? {});
        final userDetails = Map<String, dynamic>.from(author['userDetails'] ?? {});

        String video = post["videoUrl"] ?? "";
        if (video.isNotEmpty && !video.startsWith("http")) {
          video = "${Urls.baseUrl}/$video";
        }

        String image = post["imageUrl"] ?? "";
        if (image.isNotEmpty && !image.startsWith("http")) {
          image = "${Urls.baseUrl}/$image";
        }

        final counts = e['counts'] ?? {};

        final m = MyPostModel(
          id: post['_id'],
          savedRecordId: e['_id'],
          title: post['title'] ?? "",
          videoUrl: video.isNotEmpty ? video : null,
          imageUrl: image.isNotEmpty ? image : null,

          isLiked: likedPostIds.contains(post['_id']),
          isSaved: true,

          likeCount: counts['like'] ?? 0,
          commentCount: counts['comment'] ?? 0,
          watchCount: counts['watchCount'] ?? 0,
        );


        // Fix author photo
        String authorPhoto = userDetails['photo'] ?? "";
        if (authorPhoto.isNotEmpty && !authorPhoto.startsWith("http")) {
          authorPhoto = "${Urls.baseUrl}/$authorPhoto";
        }

        m.author = PostAuthor(
          id: author['_id'],
          username: author['username'] ?? userDetails['name'] ?? "",
          name: userDetails['name'],
          photo: authorPhoto,
        );

        // Set thumbnail
        if (video.isNotEmpty) {
          m.thumbnail = image.isNotEmpty ? image : null;
          _generateThumbnailAsyncSaved(m);
        } else if (image.isNotEmpty) {
          m.thumbnail = image;
        }

        newPosts.add(m);
      } catch (e) {
        print("⚠️ Error processing saved post: $e");
      }
    }

    savedPosts.value = newPosts;
    savedPosts.refresh();
    update();

    print("✅ Updated savedPosts with ${savedPosts.length} posts");
  }

  void _generateThumbnailAsyncSaved(MyPostModel post) async {
    if (post.videoUrl == null || post.videoUrl!.isEmpty) return;

    try {
      final thumb = await generateThumbnailOnce(
        postId: post.id,
        videoUrl: post.videoUrl!,
      );

      if (thumb != null) {
        final index = savedPosts.indexWhere((p) => p.id == post.id);
        if (index != -1) {
          savedPosts[index].thumbnail = thumb;
          savedPosts.refresh();
        }
      }
    } catch (e) {
      print("⚠️ Thumbnail generation failed: $e");
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

  Future<bool> deletePost(String postId) async {
    print("🗑 Deleting post => $postId");

    final res = await Get.find<NetworkClient>()
        .deleteRequest(Urls.deletePost(postId));

    print("🗑 Delete response => ${res.responseData}");

    if (res.isSuccess == true) {
      myPosts.removeWhere((p) => p.id == postId);
      taggedPosts.removeWhere((p) => p.id == postId);
      savedPosts.removeWhere((p) => p.id == postId);

      myPosts.refresh();
      taggedPosts.refresh();
      savedPosts.refresh();

      update();
      return true;
    }

    return false;
  }

}