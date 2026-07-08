import 'package:get/get.dart';
import 'package:popbom/app/urls.dart';
import 'package:popbom/core/services/network/network_client.dart';
import 'package:popbom/features/common/controllers/auth_controller.dart';
import 'package:popbom/features/home/widgets/story_section.dart';
import 'package:popbom/features/profile/controller/follow_unfollow_contoller.dart';

class StoryController extends GetxController {
  final follow = Get.find<FollowUnfollowController>();
  final _client = Get.find<NetworkClient>();

  @override
  void onInit() {
    super.onInit();
    // 🔥 Reactive update: If follow status changes/loads, re-process stories
    ever(follow.followLoaded, (_) => _processStoriesInternal());
  }

  bool loading = false;
  bool loadingUser = false;

  List<dynamic> allStories = [];
  List<Story> processedStories = [];
  List<dynamic> userStories = [];
  String? error;

  /// 👉 Load ALL USERS STORIES
  Future<void> fetchAllStories() async {
    loading = true;
    update();

    // 1. Try Load from Cache First (Instant)
    try {
      final cacheRes = await _client.getRequest(
        Urls.getAllStories,
        fromCache: true,
      );
      if (cacheRes.isSuccess && cacheRes.responseData != null) {
        allStories = cacheRes.responseData?["data"] ?? [];
        _processStoriesInternal(); // Process cached data
      }
    } catch (_) {}

    // 2. Fetch Fresh Data (Background)
    try {
      final response = await _client.getRequest(Urls.getAllStories);

      if (response.isSuccess) {
        allStories = response.responseData?["data"] ?? [];
        _processStoriesInternal(); // Process fresh data
      } else {
        error = response.errorMassage;
      }
    } catch (e) {
      error = e.toString();
    }

    loading = false;
    update();
  }

  /// 👉 Load ONLY THIS USER STORIES
  Future<void> fetchUserStories(String userId) async {
    loadingUser = true;
    update();

    try {
      final response = await _client.getRequest(Urls.getUserStories(userId));

      if (response.isSuccess) {
        userStories = response.responseData?["data"] ?? [];
        _processStoriesInternal(); // Re-process to include user stories
      } else {
        error = response.errorMassage;
      }
    } catch (e) {
      error = e.toString();
    }

    loadingUser = false;
    update();
  }

  /// 🔥 OPTIMIZATION: Process stories in Controller (not in UI build)
  void _processStoriesInternal() {
    final auth = Get.find<AuthController>();
    final currentUserId = auth.userId;

    // Wait for auth or follow data if needed, but usually we just process what we have
    // If follow data isn't loaded, we might show nothing or everything.
    // Best to check if follow is loaded.

    if (currentUserId == null) return;
    if (!follow.followLoaded.value) {
       // If follow list not loaded, maybe trigger it or wait?
       // For now, let's just proceed, assuming HomeFeed ensures it's loaded.
       // Actually, we can return if not ready.
       // return;
    }

    final Map<String, Story> storyMap = {};

    for (var s in allStories) {
      final userId = s["userId"] ?? "";
      if (userId.isEmpty) continue;

      final storyId = s["storyId"]?.toString() ?? "";
      final avatar = s["photo"] ?? "";
      final username = s["username"] ?? "";
      final videoUrl = s["videoUrl"] ?? "";

      final isFollowing = follow.followingIds.contains(userId);
      final isFollower = follow.followerIds.contains(userId);
      final isMe = userId == currentUserId;

      if (!isFollowing && !isFollower && !isMe) continue;

      storyMap.putIfAbsent(
        userId,
        () => Story(
          id: userId,
          name: username,
          avatar: avatar,
          media: [],
          userId: userId,
          storyIds: [],
        ),
      );

      if (videoUrl.isNotEmpty) {
        storyMap[userId]!.media.add(videoUrl);
        storyMap[userId]!.storyIds.add(storyId);
      }
    }

    // --- My Story ---
    if (userStories.isNotEmpty) {
      final List<String> media = [];
      final List<String> storyIds = [];

      for (var s in userStories) {
        final url = s["videoUrl"]?.toString() ?? "";
        final storyId = s["storyId"]?.toString() ?? "";

        if (url.isNotEmpty) {
          media.add(url);
          storyIds.add(storyId);
        }
      }

      final first = userStories.first;
      final avatar = first["photo"]?.toString() ?? "";

      storyMap[currentUserId] = Story(
        id: currentUserId,
        name: "Your Story",
        avatar: avatar,
        media: media,
        userId: currentUserId,
        storyIds: storyIds,
      );
    }

    final List<Story> result = [];

    // 1. Create Button
    result.add(
      const Story(
        id: "create",
        name: "Create",
        avatar: "",
        media: [],
        userId: "create",
      ),
    );

    // 2. My Story
    if (storyMap.containsKey(currentUserId)) {
      result.add(storyMap[currentUserId]!);
      storyMap.remove(currentUserId);
    }

    // 3. Others
    result.addAll(storyMap.values);

    processedStories = result;
    update(); // Notify UI
  }

  // Expose a public method if HomeFeed needs to trigger it manually (e.g. after follow refresh)
  void reprocessStories() {
    _processStoriesInternal();
  }
}
