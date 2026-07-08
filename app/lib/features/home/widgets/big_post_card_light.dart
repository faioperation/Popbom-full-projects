import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:popbom/app/urls.dart';
import 'package:popbom/features/common/ui/screen/user_profile_screen.dart';
import 'package:popbom/features/common/ui/widgets/centered_circular_progress_indicator.dart';
import 'package:popbom/features/home/controller/post_controller.dart';
import 'package:popbom/features/home/controller/video_feed_controller.dart';
import 'package:popbom/features/common/widget/comments_bottom_sheet.dart';
import 'package:popbom/features/home/ui/screen/video_feed_screen.dart';
import 'package:popbom/features/profile/controller/post_action_controller.dart';
import 'package:popbom/features/common/widget/share_sheet.dart';
import 'package:popbom/features/profile/controller/profile_controller.dart';
import 'package:video_player/video_player.dart';

class BigPostCardLight extends StatefulWidget {
  const BigPostCardLight({
    Key? key,
    required this.post,
    required this.onOpenVideo,
    required this.showMenuFrom,
  }) : super(key: key);

  final Map<String, dynamic> post;
  final VoidCallback onOpenVideo;
  final void Function(GlobalKey anchorKey) showMenuFrom;

  @override
  State<BigPostCardLight> createState() => _BigPostCardLightState();
}

class _BigPostCardLightState extends State<BigPostCardLight> {
  final actionCtrl = Get.find<PostActionsController>();
  final moreKey = GlobalKey();

  bool liked = false;
  int likeCount = 0;
  int commentCount = 0;
  bool saved = false;
  bool isMuted = true;

  late VideoPlayerController _vp;
  bool _inited = false;

  late String postId;
  late String videoUrl;
  late String name;
  late String username;
  late String photo;
  late String authorId;

  @override
  void initState() {
    super.initState();

    final p = widget.post;
    final a = p["authorId"];

    postId = p["_id"] ?? "";
    videoUrl = p["videoUrl"] ?? "";

    if (videoUrl.isNotEmpty && !videoUrl.startsWith("http")) {
      videoUrl = "${Urls.baseUrl}/$videoUrl";
    }

    username = a?["username"] ?? "unknown";
    name = a?["userDetails"]?["name"] ?? username;
    photo = a?["userDetails"]?["photo"] ?? "";
    authorId = a?["_id"] ?? "";

    likeCount = p["counts"]?["likes"] ?? 0;
    commentCount = p["counts"]?["comments"] ?? 0;

    final profile = Get.find<ProfileController>();
    final m = profile.myPosts.firstWhereOrNull((e) => e.id == postId);

    liked = m?.isLiked ?? p["isLiked"] ?? false;
    saved = m?.isSaved ?? p["isSaved"] ?? false;

    _vp = VideoPlayerController.network(videoUrl);
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      await _vp.initialize();
      await _vp.setLooping(true);
      await _vp.setVolume(0);
      await _vp.play();
      if (mounted) setState(() => _inited = true);
      await _increaseViewCount();
    } catch (_) {
      setState(() => _inited = false);
    }
  }

  @override
  void dispose() {
    _vp.dispose();
    super.dispose();
  }

  bool _viewSent = false;

  Future<void> _increaseViewCount() async {
    if (_viewSent) return; // prevent duplicates
    _viewSent = true;

    try {
      final videoFeed = Get.find<VideoFeedController>();
      final newCount = await videoFeed.increaseView(postId);

      if (newCount != null) {
        setState(() => widget.post["counts"]["views"] = newCount);

        final postCtrl = Get.find<PostController>();
        final idx = postCtrl.posts.indexWhere((e) => e["_id"] == postId);
        if (idx != -1) {
          postCtrl.posts[idx]["counts"]["views"] = newCount;
          postCtrl.update();
        }
      }
    } catch (_) {}
  }

  void _toggleMute() {
    setState(() {
      isMuted = !isMuted;
      _vp.setVolume(isMuted ? 0 : 1);
    });
  }

  void _openUserProfile() {
    if (authorId.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserProfileScreen(
          userId: authorId,
          username: username,
          avatarUrl: photo,
        ),
      ),
    );
  }

  void _onLike() async {
    final profile = Get.find<ProfileController>();
    final old = liked;

    setState(() {
      liked = !old;
      liked ? likeCount++ : likeCount--;
    });

    String? reactionId;

    if (!old) {
      reactionId = await actionCtrl.toggleLike(
        postId: postId,
        isLikedNow: true,
      );
    } else {
      final r = await actionCtrl.getReactionByPostId(postId);
      if (r != null) {
        await actionCtrl.removeReaction(r["_id"]);
      }
    }

    profile.syncLike(
      postId: postId,
      isLiked: liked,
      delta: liked ? 1 : -1,
      reactionId: reactionId,
    );
  }

  void _onSave() async {
    final profile = Get.find<ProfileController>();
    final old = saved;

    setState(() => saved = !old);

    final res = await actionCtrl.toggleSave(
      postId: postId,
      isCurrentlySaved: old,
    );

    if (res == null && mounted) {
      setState(() => saved = old);
      return;
    }

    profile.syncSave(
      postId: postId,
      isSaved: saved,
      savedRecordId: res?["savedRecordId"],
    );

    if (!saved) {
      profile.savedPosts.removeWhere((p) => p.id == postId);
      profile.savedPosts.refresh();
    }
  }

  void _openComments() {
    final cs = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => CommentsBottomSheet(
        commentCount: commentCount,
        postId: postId,
        onCommentCountChanged: (newCount) {
          if (mounted) {
            setState(() => commentCount = newCount);
          }
        },
      ),
    );
  }

  void _openShare() {
    final cs = Theme.of(context).colorScheme;

    final dynamicUrl = "https://popbom.app/post/$postId";

    showModalBottomSheet(
      context: context,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.link, color: cs.onSurface),
              title: const Text("Copy link"),
              onTap: () async {
                await Clipboard.setData(ClipboardData(text: dynamicUrl));
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.share, color: cs.onSurface),
              title: const Text("Share"),
              onTap: () async {
                await actionCtrl.sharePost(postId: postId, platform: "system");
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    void _openVideoFeed() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VideoFeedScreen(
            initialIndex: 0,
            searchResults: [
              Map<String, dynamic>.from(widget.post),
            ],
          ),
        ),
      );
    }

    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 8, 8),
            child: InkWell(
              onTap: _openUserProfile,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: photo.isNotEmpty
                        ? CachedNetworkImageProvider(
                            photo,
                            maxHeight: 100, // Optimize feed avatar
                            maxWidth: 100,
                          )
                        : const AssetImage("assets/default_user.png")
                            as ImageProvider,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: textTheme.bodyLarge?.copyWith(
                            color: cs.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '@$username',
                          style: textTheme.bodySmall?.copyWith(
                            color: cs.onSurface.withOpacity(.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          Stack(
            children: [
              GestureDetector(
                onTap: _openVideoFeed,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: AspectRatio(
                    aspectRatio: 3 / 4,
                    child: _inited
                        ? FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: _vp.value.size.width,
                              height: _vp.value.size.height,
                              child: VideoPlayer(_vp),
                            ),
                          )
                        : const Center(
                            child: CenteredCircularProgressIndicator(),
                          ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: IconButton(
                  icon: Icon(
                    isMuted ? Icons.volume_off : Icons.volume_up,
                    color: Colors.white,
                    size: 18,
                  ),
                  onPressed: _toggleMute,
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
            child: Row(
              children: [
                InkWell(
                  onTap: _onLike,
                  child: Row(
                    children: [
                      Icon(
                        liked ? Icons.favorite : Icons.favorite_border,
                        color: liked ? Colors.pink : cs.onSurface,
                      ),
                      const SizedBox(width: 6),
                      Text("$likeCount"),
                    ],
                  ),
                ),
                const SizedBox(width: 18),

                InkWell(
                  onTap: _openComments,
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icon/comment.svg',
                        width: 22,
                        colorFilter: ColorFilter.mode(
                          cs.onSurface,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text("$commentCount"),
                    ],
                  ),
                ),
                const SizedBox(width: 18),

                InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (BuildContext context) {
                        return ShareSheet(
                          shareText: "Check out this post!",
                          shareLink: "https://popbom.app/post/$postId",
                          postId: postId,
                          videoUrl: widget.post['videoUrl'],
                        );
                      },
                    );
                  },
                  child: SvgPicture.asset(
                    'assets/icon/reels_share.svg',
                    width: 22,
                    colorFilter: ColorFilter.mode(
                      cs.onSurface,
                      BlendMode.srcIn,
                    ),
                  ),
                ),

                const Spacer(),

                InkWell(
                  onTap: _onSave,
                  child: Icon(
                    saved ? Icons.bookmark : Icons.bookmark_border_outlined,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              children: [
                Icon(
                  Icons.favorite,
                  size: 16,
                  color: cs.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '$likeCount likes',
                    style: textTheme.bodySmall?.copyWith(
                      color: cs.onSurface.withOpacity(0.7),
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
