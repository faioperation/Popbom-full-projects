import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:popbom/features/auth/ui/widget/app_logo.dart';
import 'package:popbom/features/challenge/controller/feed_challenge_controller.dart';
import 'package:popbom/features/common/controllers/auth_controller.dart';
import 'package:popbom/features/common/ui/widgets/centered_circular_progress_indicator.dart';
import 'package:popbom/features/home/controller/notification_controller.dart';
import 'package:popbom/features/home/controller/post_controller.dart';
import 'package:popbom/features/home/controller/story_controller.dart';
import 'package:popbom/features/home/ui/screen/notification_screen.dart';
import 'package:popbom/features/home/ui/screen/story_or_live_screen.dart';
import 'package:popbom/features/home/widgets/big_post_card_light.dart';
import 'package:popbom/features/challenge/widget/feed_challenges_section.dart';
import 'package:popbom/features/home/widgets/home_search_delegate.dart';
import 'package:popbom/features/home/widgets/story_section.dart';
import 'package:popbom/features/profile/controller/follow_unfollow_contoller.dart';
import 'video_feed_screen.dart';

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key, this.openVideoTab});

  final VoidCallback? openVideoTab;

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  final StoryController storyCtrl = Get.put(StoryController());
  final ScrollController _scrollController = ScrollController();
  final NotificationController notificationCtrl = Get.put(
    NotificationController(),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Get.find<FeedChallengeController>().fetchFeedChallenges();
      }
    });
  }

  final int _feedCount = 6;
  static const _grey = Color(0xFFF1F3F5);

  final AuthController authCtrl = Get.find<AuthController>();
  String? _currentUserId;
  final FollowUnfollowController followCtrl =
      Get.find<FollowUnfollowController>();
  final PostController postCtrl = Get.find<PostController>();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (!postCtrl.loadingMore) {
          postCtrl.loadMore();
        }
      }
    });

    Future.microtask(() async {
      if (authCtrl.userId == null || authCtrl.userId!.isEmpty) {
        await authCtrl.getUserData();
      }

      _currentUserId = authCtrl.userId;

      if (_currentUserId == null) return;

      await followCtrl.refreshFollowing();
      await storyCtrl.fetchAllStories();
      await storyCtrl.fetchUserStories(_currentUserId!);

      postCtrl.fetchAllPosts();

      setState(() {});
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<Story> _stories = [];

  void _markStorySeen(String id) {
    final idx = _stories.indexWhere((s) => s.id == id);
    if (idx != -1 && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _stories[idx] = _stories[idx].copyWith(seen: true));
        }
      });
    }
  }

  Story? _nextOf(String currentId) {
    final idx = _stories.indexWhere((e) => e.id == currentId);
    if (idx == -1 || idx + 1 >= _stories.length) return null;
    return _stories[idx + 1];
  }

  Story? _prevOf(String currentId) {
    final idx = _stories.indexWhere((e) => e.id == currentId);
    if (idx <= 0) return null;
    return _stories[idx - 1];
  }

  // ✅ FIXED: Story open করার function
  void _openStoryAt(int index) {
    final s = _stories[index];

    // Create story এ click করলে StoryOrLiveScreen এ navigate করবে
    if (s.id == 'create') {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const StoryOrLiveScreen()));
      return;
    }

    Navigator.of(context).push<bool>(
      PageRouteBuilder<bool>(
        pageBuilder: (_, __, ___) => StoryViewer(
          story: s,
          onCompleted: () => _markStorySeen(s.id),
          nextProvider: _nextOf,
          prevProvider: _prevOf,
          onStorySeen: _trackStoryViewer,
          currentUserId: _currentUserId ?? "",
          isMyStory: s.userId == _currentUserId,
        ),
        transitionsBuilder: (_, anim, __, c) {
          final tween = Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOutQuart));
          return SlideTransition(position: anim.drive(tween), child: c);
        },
      ),
    );
  }

  void _openStory(Story story) {
    final idx = _stories.indexWhere((e) => e.id == story.id);
    if (idx != -1) {
      _openStoryAt(idx);
    }
  }

  void _openVideo(int postIndex) {
    final posts = List<Map<String, dynamic>>.from(postCtrl.posts);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            VideoFeedScreen(initialIndex: postIndex, searchResults: posts),
      ),
    );
  }

  void _openSearch() =>
      showSearch(context: context, delegate: HomeSearchDelegate());

  void _openNotify() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NotificationScreen()),
    );
  }

  void _showMoreMenu(GlobalKey anchorKey) async {
    final overlayState = Overlay.maybeOf(context);
    if (overlayState == null) return;

    final RenderBox? box =
        anchorKey.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox overlay =
        overlayState.context.findRenderObject() as RenderBox;
    if (box == null) return;

    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final Offset offset = box.localToGlobal(Offset.zero, ancestor: overlay);
    final Size size = box.size;

    await showMenu(
      context: context,
      color: cs.surface,
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height,
        overlay.size.width - offset.dx - size.width,
        0,
      ),
      items: <PopupMenuEntry>[
        PopupMenuItem(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/icon/unfollow.svg',
                width: 22,
                height: 22,
                colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.onSurface,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Unfollow',
                  style: TextStyle(color: cs.onSurface, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
        const PopupMenuItem(
          enabled: false,
          height: 8,
          child: SizedBox.shrink(),
        ),
        PopupMenuItem(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: cs.onSurface, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'About this account',
                  style: TextStyle(color: cs.onSurface, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String selectedCategory = "Trending";

  Widget _buildCategoryButton(String category) {
    final isSelected = category == selectedCategory;

    return GestureDetector(
      onTap: () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              selectedCategory = category;
            });
            switch (category) {
              case "All":
                _scrollController.jumpTo(0);
                postCtrl.fetchAllPosts();
                break;

              case "Trending":
                _scrollController.jumpTo(0);
                postCtrl.fetchTrendingPosts();
                break;

              case "Recommended":
                _scrollController.jumpTo(0);
                postCtrl.fetchRecommendedPosts();
                break;

              case "Challenges":
                _scrollController.jumpTo(0);
                postCtrl.fetchChallengePosts();
                break;
            }
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF21E9A3), Color(0xFF6DF844)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          category,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  final Map<String, List<String>> _storyViewers = {};
  final Map<String, List<String>> _storyLikers = {};

  void _trackStoryViewer(String storyId, String viewerId) {
    if (!_storyViewers.containsKey(storyId)) {
      _storyViewers[storyId] = [];
    }
    if (!_storyViewers[storyId]!.contains(viewerId)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _storyViewers[storyId]!.add(viewerId);
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    const _grey = Color(0xFFEFEFEF);

    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        backgroundColor: cs.background,
        appBar: AppBar(
          backgroundColor: cs.background,
          elevation: 0,
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          title: Row(
            children: [
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: PopBomLogo(height: 30, width: 30),
              ),
              const SizedBox(width: 8),
            ],
          ),
          actions: [
            IconButton(
              onPressed: _openSearch,
              icon: Icon(Icons.search, color: cs.onBackground),
              tooltip: 'Search',
            ),
            Obx(() {
              final count = notificationCtrl.unreadCount;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    onPressed: _openNotify,
                    icon: Icon(Icons.notifications, color: cs.onBackground),
                    tooltip: 'Notification',
                  ),

                  if (count > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          count > 99 ? '99+' : count.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            }),

            const SizedBox(width: 4),
          ],
        ),
        body: SafeArea(
          top: false,
          child: RefreshIndicator(
            color: Color(0xFF6DF844),
            onRefresh: () async {
              await followCtrl.refreshFollowing();
              await storyCtrl.fetchAllStories();
              await storyCtrl.fetchUserStories(_currentUserId!);
              await postCtrl.fetchAllPosts();
              setState(() {});
            },
            child: CustomScrollView(
              controller: _scrollController,
              cacheExtent: 400,
              slivers: [
                SliverToBoxAdapter(
                  child: GetBuilder<StoryController>(
                    builder: (c) {
                      if (c.loading || c.loadingUser) {
                        return const SizedBox(height: 104);
                      }

                      final Map<String, Story> storyMap = {};
                      final followCtrl = Get.find<FollowUnfollowController>();

                      if (!followCtrl.followLoaded.value) {
                        return const SizedBox(height: 104);
                      }

                      // 🔥 OPTIMIZATION: Use pre-processed stories from Controller
                      _stories = c.processedStories;

                      // If controller hasn't processed/loaded yet, show empty or loading
                      if (_stories.isEmpty && !c.loading) {
                        // Fallback: If not processed, maybe try to process?
                        // But usually controller does it on fetch.
                        // We can show just "Create" button if empty?
                        _stories = [
                          Story(
                            id: "create",
                            name: "Create",
                            avatar: "",
                            media: const [],
                            userId: "create",
                          ),
                        ];
                      }

                      return SizedBox(
                        height: 104,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          scrollDirection: Axis.horizontal,
                          itemCount: _stories.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (_, i) => StoryItem(
                            story: _stories[i],
                            onTap: () => _openStoryAt(i),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                SliverToBoxAdapter(child: const FeedChallengesBlock()),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildCategoryButton("All"),
                          _buildCategoryButton("Trending"),
                          _buildCategoryButton("Recommended"),
                          _buildCategoryButton("Challenges"),
                        ],
                      ),
                    ),
                  ),
                ),

                GetBuilder<PostController>(
                  builder: (c) {
                    if (c.loading && c.posts.isEmpty) {
                      return const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: CenteredCircularProgressIndicator(),
                        ),
                      );
                    }

                    if (c.posts.isEmpty) {
                      return const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(child: Text("No Posts Found")),
                      );
                    }

                    return SliverList(
                      delegate: SliverChildBuilderDelegate((context, i) {
                        if (i == c.posts.length) {
                          return c.loadingMore
                              ? const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                    child: CenteredCircularProgressIndicator(),
                                  ),
                                )
                              : const SizedBox();
                        }

                        final post = c.posts[i];
                        return Padding(
                          padding: const EdgeInsets.all(6),
                          child: BigPostCardLight(
                            post: post,
                            onOpenVideo: () => _openVideo(i),
                            showMenuFrom: _showMoreMenu,
                          ),
                        );
                      }, childCount: c.posts.length + 1),
                    );
                  },
                ),

                SliverToBoxAdapter(child: const SizedBox(height: 8)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
