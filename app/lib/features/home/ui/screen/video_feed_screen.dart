import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:popbom/app/urls.dart';
import 'package:popbom/core/cache/video_cache_manager.dart';
import 'package:popbom/features/common/ui/screen/app_shell.dart';
import 'package:popbom/features/common/ui/screen/camera_record_screen.dart';
import 'package:popbom/features/common/ui/screen/custom_bottom_nav_bar.dart';
import 'package:popbom/features/common/ui/screen/user_profile_screen.dart';
import 'package:popbom/features/common/ui/widgets/centered_circular_progress_indicator.dart';
import 'package:popbom/features/common/widget/comments_bottom_sheet.dart';
import 'package:popbom/features/common/controllers/auth_controller.dart';
import 'package:popbom/features/home/controller/video_feed_controller.dart';
import 'package:popbom/features/home/models/video_item_model.dart';
import 'package:popbom/features/home/services/live_sevices.dart';
import 'package:popbom/features/profile/controller/follow_unfollow_contoller.dart';
import 'package:popbom/features/gift/controller/gift_controller.dart';
import 'package:popbom/features/profile/controller/post_action_controller.dart';
import 'package:popbom/features/profile/controller/profile_controller.dart';
import 'package:popbom/features/home/services/live_socket_service.dart';
import 'package:popbom/features/common/widget/share_sheet.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VideoFeedScreen extends StatefulWidget {
  const VideoFeedScreen({
    super.key,
    this.onBack,
    this.onPlayStateChanged,
    this.videoUrl,
    this.initialIndex = 0,
    this.searchResults,

  });

  final VoidCallback? onBack;
  final ValueChanged<bool>? onPlayStateChanged;
  final String? videoUrl;
  final int initialIndex;
  final List<dynamic>? searchResults;

  @override
  State<VideoFeedScreen> createState() => _VideoFeedScreenState();
}

class _VideoFeedScreenState extends State<VideoFeedScreen>
    with WidgetsBindingObserver {
  String _tabTitle(FeedType t) {
    switch (t) {
      case FeedType.live:
        return "LIVE";
      case FeedType.steam:
        return "STEAM";
      case FeedType.discover:
        return "Discover";
      case FeedType.following:
        return "Following";
      case FeedType.your5:
        return "Your5";
    }
  }

  final tabs = const [
    FeedType.live,
    FeedType.steam,
    FeedType.discover,
    FeedType.following,
    FeedType.your5,
  ];

  int tabIndex = 4; // Default “Your5”
  final Set<String> _viewedVideoIds = {};

  final giftC = Get.put(GiftController());

  final VideoFeedController _videoFeedController =
  Get.find<VideoFeedController>();

  final actionCtrl = Get.find<PostActionsController>();
  final profileCtrl = Get.find<ProfileController>();
  final followCtrl = Get.find<FollowUnfollowController>();

  List<VideoItem> _items = [];
  late PageController _pageController;
  final Map<int, VideoPlayerController> _controllers = {};
  int _current = 0;
  bool _showHeart = false;
  bool isMuted = false;

  int _bottomIndex = 0;

  bool get isLiveTab => _videoFeedController.currentFeed.value == FeedType.live;

  bool get isLivePlaying {
    return isLiveTab &&
        _items.isNotEmpty &&
        _items[_current].isLive;
  }


  bool get isSearchMode =>
      widget.searchResults != null && widget.searchResults!.isNotEmpty;

  final TextEditingController _liveCommentCtrl = TextEditingController();



  static const Color _green1 = Color(0xff21E6A0);
  static const Color _green2 = Color(0xFF6DF844);
  static const double _overlayBarH = 64.0;
  static const int _keepAliveRange = 1;

  final Set<String> _cachedUrls = {};

  @override
  void deactivate() {
    _pauseCurrentVideo();
    super.deactivate();
  }

  void _sendLiveComment() {
    if (!isLiveTab || _items.isEmpty) return;

    final text = _liveCommentCtrl.text.trim();
    if (text.isEmpty) return;

    final liveItem = _items[_current];
    final auth = Get.find<AuthController>();

    LiveSocketService().sendComment(
      liveItem.id,
      text,
      auth.userModel?.username ?? "User",
      auth.userModel?.photo ?? "",
    );

    _liveCommentCtrl.clear();
  }


  void _sendLiveLike() {
    if (!isLiveTab || _items.isEmpty) return;

    final liveItem = _items[_current];
    LiveSocketService().sendLike(liveItem.id);
  }




  Future<VideoPlayerController> createCachedController(String url) async {
    try {
      final file = await VideoCacheManager().getSingleFile(url);
      return VideoPlayerController.file(file);
    } catch (e) {
      // fallback
      return VideoPlayerController.networkUrl(Uri.parse(url));
    }
  }

  Future<void> precacheVideo(String url) async {
    if (url.isEmpty || _cachedUrls.contains(url)) return;

    try {
      _cachedUrls.add(url);
      await VideoCacheManager().downloadFile(url);
      debugPrint("✅ Video cached: $url");
    } catch (e) {
      _cachedUrls.remove(url);
      debugPrint("❌ Video cache failed: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    if (widget.searchResults != null && widget.searchResults!.isNotEmpty) {
      _items = _videoFeedController.mapSearchItems(widget.searchResults!);
    }

    _current = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    tabIndex = tabs.indexOf(_videoFeedController.currentFeed.value);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isSearchMode && _videoFeedController.videos.isEmpty) {
        _videoFeedController.loadVideosByFeed(FeedType.your5);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.onPlayStateChanged?.call(false);
    for (final c in _controllers.values) {
      if (c.value.isInitialized) {
        c.pause();
      }
      c.dispose();
    }
    _controllers.clear();
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final c = _controllers[_current];
    if (c == null || !c.value.isInitialized) return;

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      // 🔥 অন্য screen এ গেলে / app background এ গেলে
      c.pause();
      widget.onPlayStateChanged?.call(false);
    }

    if (state == AppLifecycleState.resumed) {
      // ❌ auto play করবে না
      // user চাইলে tap করে play করবে
    }
  }

  void _pauseCurrentVideo() {
    final c = _controllers[_current];
    if (c != null && c.value.isInitialized && c.value.isPlaying) {
      c.pause();
      widget.onPlayStateChanged?.call(false);
    }
  }

  void _cleanupControllers(int current) {
    _controllers.keys
        .where((i) => (i - current).abs() > _keepAliveRange)
        .toList()
        .forEach((i) {
      _controllers[i]?.dispose();
      _controllers.remove(i);
    });
  }

  // helper: dynamic → int
  int _asInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  Widget _buildTopTabs() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 6,
        ),
        child: Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(tabs.length, (i) {
                    final selected = tabIndex == i;
                    return GestureDetector(
                      onTap: () => _onTabChange(i),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _tabTitle(tabs[i]),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: selected ? Colors.white : Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 2),
                            if (selected)
                              Container(
                                height: 2,
                                width: 20,
                                color: Colors.white,
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            const Icon(
              CupertinoIcons.search,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 6),
          ],
        ),
      ),
    );
  }

  bool _isPlayingNow() {
    final cur = _controllers[_current];
    return cur != null && cur.value.isInitialized && cur.value.isPlaying;
  }

  void _notifyPlayState() {
    widget.onPlayStateChanged?.call(_isPlayingNow());
  }

  Future<void> _initController(int index, {bool autoplay = true}) async {
    if (index < 0 || index >= _items.length) return;
    if (_controllers[index] != null) return;

    final item = _items[index];
    if (item.isLive || item.url.isEmpty) return;

    // 🔥 ensure cache
    await precacheVideo(item.url);

    final file = await VideoCacheManager().getSingleFile(item.url);
    final controller = VideoPlayerController.file(file);

    _controllers[index] = controller;

    await controller.initialize();
    controller.setLooping(true);
    controller.setVolume(isMuted ? 0 : 1);

    if (autoplay) {
      await controller.play();
    }
  }

  void _resetControllers() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _controllers.clear();
  }

  Future<void> _onPageChanged(int index) async {
    final prev = _current;
    _current = index;
    final item = _items[index];
    // preload next file + controller
    if (index + 1 < _items.length) {
      precacheVideo(_items[index + 1].url);
      _initController(index + 1, autoplay: false);
    }

    // 🔴 LIVE skip
    if (item.isLive) {
      _pauseCurrentVideo();
      _cleanupControllers(index);
      _notifyPlayState();
      return;
    }

    final prevCtl = _controllers[prev];
    if (prevCtl != null && prevCtl.value.isInitialized) {
      await prevCtl.pause();
      await prevCtl.seekTo(Duration.zero);
    }

    await _initController(index);

    final curCtl = _controllers[index];
    if (curCtl != null && curCtl.value.isInitialized) {
      await curCtl.setVolume(isMuted ? 0 : 1);
      await curCtl.play();
    }

    // preload next
    if (index + 1 < _items.length) {
      _initController(index + 1, autoplay: false);
    }

    // cleanup old controllers
    _cleanupControllers(index);

    // 🔥 VIEW COUNT – ONLY ONCE
    final id = _items[index].id;
    if (!_viewedVideoIds.contains(id)) {
      _viewedVideoIds.add(id);

      final newCount = await _videoFeedController.increaseView(id);
      if (newCount != null && mounted) {
        setState(() {
          _items[index].views = newCount;
        });
      }
    }

    if (mounted) {
      _notifyPlayState();
    }
  }

  Future<void> _togglePlayPause() async {
    final item = _items[_current];

    // 🔴 LIVE tap disabled
    if (item.isLive) return;
    final c = _controllers[_current];
    if (c == null || !c.value.isInitialized) return;

    if (c.value.isPlaying) {
      await c.pause();
    } else {
      await c.play();
    }
    if (mounted) {
      setState(() {
        widget.onPlayStateChanged?.call(!_isPlayingNow());
      });
      _notifyPlayState();
    }
  }

  void _toggleMute() {
    setState(() {
      isMuted = !isMuted;
      final c = _controllers[_current];
      if (c != null && c.value.isInitialized) {
        c.setVolume(isMuted ? 0 : 1);
      }
    });
  }

  void _doubleTapLike() {
    setState(() {
      final item = _items[_current];
      if (!item.isLiked) {
        item.isLiked = true;
        item.likes += 1;
      }
      _showHeart = true;
    });
    Future.delayed(const Duration(milliseconds: 550), () {
      if (mounted) setState(() => _showHeart = false);
    });
  }

  String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }

  void _goHome() {
    _pauseCurrentVideo();
    final nav = Navigator.of(context);
    if (nav.canPop()) {
      nav.pop();
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AppShell()),
          (route) => false,
    );
  }

  void _handleBack() => (widget.onBack ?? _goHome)();

  void _onTabChange(int i) {
    setState(() {
      tabIndex = i;
      _current = 0;
    });

    _viewedVideoIds.clear();
    _resetControllers();

    _pageController.dispose();
    _pageController = PageController(initialPage: 0);

    _videoFeedController.changeFeed(tabs[i]);
  }

  void _openComments(VideoItem item) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => CommentsBottomSheet(
        commentCount: item.comments,
        postId: item.id, // 🔥 এখানে আসল postId গেলো
        onCommentCountChanged: (newCount) {
          setState(() {
            item.comments = newCount;
          });
        },
      ),
    );
  }

  void _openGiftSheet() async {
    final c = _controllers[_current];
    if (c != null && c.value.isInitialized && c.value.isPlaying) {
      await c.pause();
      _notifyPlayState();
    }

    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final gifts = const [
      ('🪙', 'Coins'),
      ('❤️', 'Hearts'),
      ('🌹', 'Roses'),
      ('⭐', 'Stars'),
      ('🔥', 'Fireworks'),
    ];
    final selected = <int>{};

    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: cs.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) {
          Widget tile(int i) {
            final on = selected.contains(i);
            return InkWell(
              onTap: () =>
                  setLocal(() => on ? selected.remove(i) : selected.add(i)),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 98,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: on ? cs.surface : cs.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: on ? _green1 : cs.outlineVariant,
                    width: on ? 1.6 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(gifts[i].$1, style: const TextStyle(fontSize: 26)),
                    const SizedBox(height: 6),
                    Text(
                      gifts[i].$2,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Send a gift',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: List.generate(gifts.length, tile),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 46,
                    width: double.infinity,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_green1, _green2],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: selected.isEmpty ? cs.surfaceVariant : null,
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        onPressed: selected.isEmpty
                            ? null
                            : () async {
                          Navigator.pop(context);

                          final item =
                          _items[_current]; // current video post
                          final postId = item.id;

                          // selected gift index → gift type map
                          const giftTypes = [
                            "coin",
                            "heart",
                            "rose",
                            "star",
                            "fire",
                          ];

                          for (var i in selected) {
                            final giftType = giftTypes[i];

                            final ok = await giftC.sendGift(
                              postId: postId,
                              giftType: giftType,
                              userId: item.userId,
                              amount: 1,
                            );

                            if (ok) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Sent $giftType to post author 🎁",
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Failed to send $giftType",
                                  ),
                                ),
                              );
                            }
                          }
                        },
                        child: Text(
                          selected.isEmpty
                              ? 'Select gifts'
                              : 'Send (${selected.length})',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _openShareSheet(String link) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return ShareSheet(
          shareText: "Check out this post!",
          shareLink: link,
          postId: link,
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const Key('video_feed_screen'),
      onVisibilityChanged: (info) {
        final visible = info.visibleFraction > 0.5;

        final c = _controllers[_current];
        if (c == null || !c.value.isInitialized) return;

        if (!visible && c.value.isPlaying) {
          c.pause();
          widget.onPlayStateChanged?.call(false);
        }
      },
      child: WillPopScope(
        onWillPop: () async {
          _goHome();
          return false;
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Obx(() {
                final _ = _videoFeedController.currentFeed.value;
                final isLoading =_videoFeedController.loading.value;
                if (!isSearchMode && _videoFeedController.loading.value) {
                  return const Center(
                    child: CenteredCircularProgressIndicator(),
                  );
                }

                final apiVideos = isSearchMode
                    ? widget.searchResults!
                    : _videoFeedController.videos;

                if (apiVideos.isEmpty) {
                  return const Center(
                    child: Text(
                      "No videos found",
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }


                // Determine which list to use
                List<VideoItem> currentItems;
                if (isSearchMode) {
                  currentItems = _items; // mapped in initState
                } else {
                  currentItems = _videoFeedController.mappedItems;
                }

                if (currentItems.isEmpty) {
                  return const Center(
                    child: Text(
                      "No videos found",
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }
                
                // Sync _items for logic usage outside build
                if (!isSearchMode) {
                   _items = currentItems;
                   if (_items.isNotEmpty && _controllers[_current] == null) {
                      WidgetsBinding.instance.addPostFrameCallback((_) async {
                        if (mounted) {
                          await _initController(_current);
                          _notifyPlayState();
                        }
                      });
                   }
                }

                return PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.vertical,
                  onPageChanged: _onPageChanged,
                  itemCount: currentItems.length,
                  itemBuilder: (context, index) {
                    final item = currentItems[index];

                    if (item.isLive) {
                      return Stack(
                        children: [
                          LiveAudiencePlayer(item: item),
                          _buildTopTabs(),
                        ],
                      );
                    }

                    final controller = _controllers[index];

                    final isPlaying =
                        controller != null &&
                            controller.value.isInitialized &&
                            controller.value.isPlaying;

                    final double safeBottom = MediaQuery.of(
                      context,
                    ).padding.bottom;
                    final double overlayTotal = _overlayBarH + safeBottom;

                    return GestureDetector(
                      onTap: _togglePlayPause,
                      onDoubleTap: _doubleTapLike,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child:
                            controller != null &&
                                controller.value.isInitialized
                                ? FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox(
                                width: controller.value.size.width,
                                height: controller.value.size.height,
                                child: VideoPlayer(controller),
                              ),
                            )
                                : const Center(
                              child: CenteredCircularProgressIndicator(),
                            ),
                          ),

                          if (_showHeart && index == _current)
                            const Center(
                              child: Icon(
                                Icons.favorite,
                                color: Colors.white70,
                                size: 120,
                              ),
                            ),

                          if (!isPlaying) _buildTopTabs(),



                          if (isLiveTab)
                            AnimatedPositioned(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOut,
                              left: 0,
                              right: 0,

                              top: isPlaying ? 8 : 48,

                              child: SafeArea(
                                bottom: false,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    children: [
                                      CircleAvatar(
                                        radius: 16,
                                        backgroundImage:
                                        item.userAvatar.isNotEmpty
                                            ? NetworkImage(item.userAvatar)
                                            : null,
                                        backgroundColor: Colors.grey.shade800,
                                        child: item.userAvatar.isEmpty
                                            ? const Icon(
                                          Icons.person,
                                          color: Colors.white,
                                          size: 18,
                                        )
                                            : null,
                                      ),

                                      const SizedBox(width: 8),

                                      Text(
                                        item.userName,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),

                                      const SizedBox(width: 6),

                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: const Text(
                                          "LIVE",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),

                                      const Spacer(),

                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(.45),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.remove_red_eye,
                                              size: 14,
                                              color: Colors.white70,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              _fmt(item.views),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                          if (controller != null &&
                              controller.value.isInitialized &&
                              !controller.value.isPlaying)
                            const Center(
                              child: Icon(
                                Icons.play_circle_fill,
                                size: 68,
                                color: Colors.white70,
                              ),
                            ),

                          if (tabIndex != 0)
                            Positioned(
                              right: 12,
                              bottom: isPlaying ? 110 : (overlayTotal + 46),
                              child: _ActionRail(
                                item: item,
                                isMuted: isMuted,
                                onLike: () async {
                                  final postId = item.id;
                                  if (postId.isEmpty) return;

                                  final profile = profileCtrl;
                                  final old = item.isLiked;

                                  setState(() {
                                    item.isLiked = !old;
                                    item.likes += item.isLiked ? 1 : -1;
                                  });

                                  bool success = false;
                                  String? reactionId;

                                  if (!old) {
                                    reactionId = await actionCtrl.toggleLike(
                                      postId: postId,
                                      isLikedNow: true,
                                    );
                                    success = reactionId != null;
                                  } else {
                                    if (item.reactionId == null) {
                                      final r = await actionCtrl
                                          .getReactionByPostId(postId);
                                      item.reactionId = r?["_id"];
                                    }

                                    if (item.reactionId != null) {
                                      success = await actionCtrl.removeReaction(
                                        item.reactionId!,
                                      );
                                      if (success) item.reactionId = null;
                                    }
                                  }

                                  if (!success) {
                                    setState(() {
                                      item.isLiked = old;
                                      item.likes += item.isLiked ? 1 : -1;
                                    });
                                    return;
                                  }

                                  profile.syncLike(
                                    postId: postId,
                                    isLiked: item.isLiked,
                                    delta: item.isLiked ? 1 : -1,
                                    reactionId: reactionId,
                                  );
                                },
                                onComment: () => _openComments(item),
                                onSave: () async {
                                  final postId = item.id;
                                  if (postId.isEmpty) return;

                                  final profile = profileCtrl;
                                  final old = item.saved;

                                  setState(() => item.saved = !old);

                                  final result = await actionCtrl.toggleSave(
                                    postId: postId,
                                    isCurrentlySaved: old,
                                  );

                                  if (result == null) {
                                    setState(() => item.saved = old);
                                    return;
                                  }

                                  profile.syncSave(
                                    postId: postId,
                                    isSaved: item.saved,
                                    savedRecordId: result["savedRecordId"],
                                  );

                                  if (!item.saved) {
                                    profile.savedPosts.removeWhere(
                                          (p) => p.id == postId,
                                    );
                                    profile.savedPosts.refresh();
                                  }
                                },
                                onShare: () => _openShareSheet(item.shareLink),
                                onGift: _openGiftSheet,
                                onToggleMute: _toggleMute,
                              ),
                            ),

                          if (!isPlaying && tabIndex != 0)
                            Positioned(
                              left: 12,
                              right: 80,
                              bottom: overlayTotal + 14,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.userName.isNotEmpty
                                        ? item.userName
                                        : "@unknown",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.caption,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              }),
              if (!isLiveTab && !_isPlayingNow())
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Builder(
                    builder: (context) {
                      final double safeBottom = MediaQuery.of(context).padding.bottom;
                      final double overlayTotal = _overlayBarH + safeBottom;
                      return Container(
                        height: overlayTotal,
                        color: Colors.black,
                      );
                    },
                  ),
                ),
              if (isLiveTab)
                Positioned(
                  left: 8,
                  right: 8,
                  bottom: 8,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.12),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: _sendLiveLike,
                          icon: const Icon(
                            Icons.favorite,
                            color: Colors.pinkAccent,
                            size: 28,
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.10),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _liveCommentCtrl,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(
                                    hintText: 'Send a comment…',
                                    hintStyle: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                  ),
                                  onSubmitted: (_) => _sendLiveComment(),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.send,
                                  color: Colors.white,
                                ),
                                onPressed: _sendLiveComment,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              if (!isLiveTab && !_isPlayingNow())
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SafeArea(
                    top: false,
                    child: SizedBox(
                      height: _overlayBarH,
                      child: CustomBottomNavBar(
                        currentIndex: _bottomIndex,
                        onTap: (i) {
                          _pauseCurrentVideo();
                          if (i == 2) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CameraRecordScreen(),
                              ),
                            );
                            return;
                          }
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) => AppShell(initialIndex: i),
                            ),
                                (route) => false,
                          );
                        },
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionRail extends StatelessWidget {
  const _ActionRail({
    required this.item,
    required this.isMuted,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onSave,
    required this.onGift,
    required this.onToggleMute,
  });

  final VideoItem item;
  final bool isMuted;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onSave;
  final VoidCallback onGift;
  final VoidCallback onToggleMute;

  String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            if (item.userId.isEmpty) return;
            (context.findAncestorStateOfType<_VideoFeedScreenState>())
                ?._pauseCurrentVideo();

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => UserProfileScreen(
                  userId: item.userId,
                  username: item.userName.replaceFirst("@", ""),
                  avatarUrl: item.userAvatar,
                ),
              ),
            );
          },

          child: CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey.shade800,
            backgroundImage: item.userAvatar.isNotEmpty
                ? NetworkImage(item.userAvatar)
                : null,
            child: item.userAvatar.isEmpty
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),
        ),

        const SizedBox(height: 14),
        IconButton(
          onPressed: onLike,
          iconSize: 28,
          icon: Icon(
            item.isLiked ? Icons.favorite : Icons.favorite_border,
            color: item.isLiked ? Colors.pinkAccent : Colors.white,
          ),
        ),
        Text(
          _fmt(item.likes),
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
        const SizedBox(height: 12),
        IconButton(
          onPressed: onComment,
          iconSize: 28,
          icon: SvgPicture.asset(
            'assets/icon/comment.svg',
            width: 22,
            height: 22,
            colorFilter: ColorFilter.mode(
              Theme.of(context).colorScheme.onSurface,
              BlendMode.srcIn,
            ),
          ),
          color: Colors.white,
        ),
        Text(
          _fmt(item.comments),
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
        const SizedBox(height: 12),
        IconButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              builder: (BuildContext context) {
                return ShareSheet(
                  shareText: "Check out this post!",
                  shareLink: "https://popbom.app/post/${item.id}",
                  postId: item.id,
                  videoUrl: item.url,
                );
              },
            );
          },
          iconSize: 28,
          icon: SvgPicture.asset(
            'assets/icon/share.svg',
            width: 22,
            height: 22,
            colorFilter: ColorFilter.mode(
              Theme.of(context).colorScheme.onSurface,
              BlendMode.srcIn,
            ),
          ),
          color: Colors.white,
        ),
        Text(
          _fmt(item.shares),
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
        const SizedBox(height: 12),
        IconButton(
          onPressed: onSave,
          iconSize: 28,
          icon: Icon(item.saved ? Icons.bookmark : Icons.bookmark_border),
          color: Colors.white,
        ),
        Text(
          _fmt(item.saves),
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
        const SizedBox(height: 12),
        IconButton(
          onPressed: onGift,
          iconSize: 26,
          icon: const Icon(CupertinoIcons.gift),
          color: Colors.white,
        ),
        const SizedBox(height: 24),
        IconButton(
          onPressed: onToggleMute,
          iconSize: 22,
          icon: Icon(
            isMuted ? Icons.volume_off : Icons.volume_up,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}




class LiveAudiencePlayer extends StatefulWidget {
  final VideoItem item;

  const LiveAudiencePlayer({required this.item});

  @override
  State<LiveAudiencePlayer> createState() => _LiveAudiencePlayerState();
}

class _LiveAudiencePlayerState extends State<LiveAudiencePlayer>
    with AutomaticKeepAliveClientMixin {
  late final RtcEngine _engine;
  bool _joined = false;
  final _authController = Get.find<AuthController>();
  int? _remoteUid;

  // Chat & Like state
  final List<dynamic> _comments = [];
  final TextEditingController _commentCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  bool _heartVisible = false;
  Timer? _heartTimer;

  bool _hasError = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initAgora();
    _joinLiveApi();
    _connectSocket();
  }

  Future<void> _initAgora() async {
    try {
      setState(() => _hasError = false);
      _engine = createAgoraRtcEngine();

      await _engine.initialize(
        const RtcEngineContext(
          appId: "9f667b521f6b4797ba2ab29ec0f9a0e0",
          channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        ),
      );

      await _engine.setClientRole(role: ClientRoleType.clientRoleAudience);

      _engine.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (connection, elapsed) {
            debugPrint("✅ Joined channel ${connection.channelId}");
          },

          onUserJoined: (connection, uid, elapsed) {
            debugPrint("👤 Host joined with uid: $uid");
            if (mounted) {
              setState(() {
                _remoteUid = uid;
              });
            }
          },

          onUserOffline: (connection, uid, reason) {
            debugPrint("❌ Host left");
            if (mounted) {
              setState(() {
                _remoteUid = null;
              });
            }
          },
        ),
      );

      final tokenRes = await LiveService.getAgoraToken(
        channel: widget.item.liveChannel!,
        isBroadcaster: false,
        bearerToken: _authController.accessToken!,
      );

      await _engine.joinChannel(
        token: tokenRes.token,
        channelId: widget.item.liveChannel!,
        uid: tokenRes.uid,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleAudience,
          autoSubscribeVideo: true,
          autoSubscribeAudio: true,
        ),
      );
    } catch (e) {
      debugPrint("❌ _initAgora Error: $e");
      if (mounted) setState(() => _hasError = true);
    }
  }

  void _connectSocket() {
    final token = _authController.accessToken;
    if (token != null) {
      LiveSocketService().connect(token);
    }

    final liveId = widget.item.id;
    final socket = LiveSocketService();

    socket.onNewComment((data) {
      if (data["liveId"] == liveId && mounted) {
        setState(() {
          _comments.add(data);
        });
        _scrollToBottom();
      }
    });

    socket.onNewLike((data) {
      if (data["liveId"] == liveId) {
        _showHeartAnimation();
      }
    });
  }


  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _showHeartAnimation() {
    if (mounted) {
      setState(() => _heartVisible = true);
      _heartTimer?.cancel();
      _heartTimer = Timer(const Duration(milliseconds: 800), () {
        if (mounted) setState(() => _heartVisible = false);
      });
    }
  }

  Future<void> _joinLiveApi() async {
    final token = _authController.accessToken;
    if (token != null) {
      await LiveService.joinLive(
        liveId: widget.item.id,
        bearerToken: token,
      );
    }
  }

  Future<void> _leaveLiveApi() async {
    final token = _authController.accessToken;
    if (token != null) {
      await LiveService.leaveLive(
        liveId: widget.item.id,
        bearerToken: token,
      );
    }
  }


  @override
  void dispose() {
    LiveSocketService().offNewComment();
    LiveSocketService().offNewLike();
    LiveSocketService().disconnect();
    _leaveLiveApi();

    _heartTimer?.cancel();
    _commentCtrl.dispose();
    _scrollCtrl.dispose();

    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 110,
      left: 16,
      right: 16,
      child: Row(

        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: widget.item.userAvatar.isNotEmpty
                ? NetworkImage(widget.item.userAvatar)
                : null,
            child: widget.item.userAvatar.isEmpty
                ? const Icon(Icons.person, size: 20)
                : null,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.item.userName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  "LIVE",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.close, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    return Positioned(
      left: 16,
      bottom: 80,
      right: 100,
      height: 200,
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          return const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black],
            stops: [0.0, 0.2],
          ).createShader(bounds);
        },
        blendMode: BlendMode.dstIn,
        child: ListView.separated(
          controller: _scrollCtrl,
          itemCount: _comments.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (ctx, i) {
            final c = _comments[i];
            final name = c["username"] ?? "User";
            final msg = c["message"] ?? "";
            return Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: "$name: ",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  TextSpan(
                    text: msg,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Stack(
      children: [
        Container(
          color: Colors.black,
          child: _remoteUid != null
              ? AgoraVideoView(
            controller: VideoViewController(
              rtcEngine: _engine,
              canvas: VideoCanvas(uid: _remoteUid),
            ),
          )
              : Center(
            child: _hasError
                ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Connection Failed",
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _initAgora,
                  child: const Text("Retry"),
                )
              ],
            )
                : const CenteredCircularProgressIndicator(),
          ),
        ),

        _buildTopBar(),
        _buildChatList(),

        if (_heartVisible)
          const Center(
            child: Icon(Icons.favorite, color: Colors.pinkAccent, size: 100),
          ),
      ],
    );
  }
}

class MockLivePlayer extends StatefulWidget {
  final VideoItem item;

  const MockLivePlayer({required this.item});

  @override
  State<MockLivePlayer> createState() => _MockLivePlayerState();
}

class _MockLivePlayerState extends State<MockLivePlayer> {
  late Timer _viewerTimer;

  @override
  void initState() {
    super.initState();
    _viewerTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      setState(() {
        widget.item.views += 1;
      });
    });
  }

  @override
  void dispose() {
    _viewerTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Text(
          "🔴 LIVE\n${widget.item.userName}\n👀 ${widget.item.views}",
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 22),
        ),
      ),
    );
  }
}