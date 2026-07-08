import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:popbom/app/urls.dart';
import 'package:popbom/features/home/controller/video_feed_controller.dart';
import 'package:popbom/features/profile/controller/profile_controller.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerInline extends StatefulWidget {
  final String url;
  final String postId;

  const VideoPlayerInline({
    required this.url,
    required this.postId,
  });

  @override
  State<VideoPlayerInline> createState() => _VideoPlayerInlineState();
}

class _VideoPlayerInlineState extends State<VideoPlayerInline> {
  late VideoPlayerController controller;
  bool isReady = false;

  @override
  void initState() {
    super.initState();

    String videoUrl = widget.url.trim();

    if (!videoUrl.startsWith("http")) {
      videoUrl = "${Urls.baseUrl}/$videoUrl";
    }

    controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));

    controller.initialize().then((_) async {
      if (!mounted) return;

      setState(() => isReady = true);

      controller.play();
      controller.setLooping(true);

      // 🔥 AUTO-INCREMENT VIEW COUNT HERE
      await _increaseViewCount();
    });
  }

  /// 🔥 NEW FUNCTION
  Future<void> _increaseViewCount() async {
    try {
      final videoFeed = Get.find<VideoFeedController>();

      // postId extract from URL
      final postId = widget.postId;

      if (postId.isEmpty) return;

      final newCount = await videoFeed.increaseView(postId);

      if (newCount != null) {
        final profile = Get.find<ProfileController>();

        /// Update in myPosts
        final i1 = profile.myPosts.indexWhere((p) => p.id == postId);
        if (i1 != -1) {
          profile.myPosts[i1].watchCount = newCount;
          profile.myPosts.refresh();
        }

        /// Update in taggedPosts
        final i2 = profile.taggedPosts.indexWhere((p) => p.id == postId);
        if (i2 != -1) {
          profile.taggedPosts[i2].watchCount = newCount;
          profile.taggedPosts.refresh();
        }

        /// Update in savedPosts
        final i3 = profile.savedPosts.indexWhere((p) => p.id == postId);
        if (i3 != -1) {
          profile.savedPosts[i3].watchCount = newCount;
          profile.savedPosts.refresh();
        }
      }
    } catch (e) {
      print("⚠ view count update failed: $e");
    }
  }


  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isReady) {
      return const SizedBox(
        height: 300,
        child: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return AspectRatio(
      aspectRatio:
      controller.value.aspectRatio == 0 ||
          controller.value.aspectRatio.isNaN
          ? 1 // fallback aspect ratio
          : controller.value.aspectRatio,
      child: VideoPlayer(controller),
    );
  }
}
