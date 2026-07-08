import 'dart:io';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:popbom/features/chat/controller/chat_list_controller.dart';
import 'package:popbom/features/common/controllers/user_profile_controller.dart';
import 'package:popbom/features/chat/ui/screen/chat_screen.dart';
import 'package:popbom/core/services/network/network_client.dart';
import 'package:popbom/app/urls.dart';
import 'package:popbom/features/common/ui/widgets/centered_circular_progress_indicator.dart';
import 'package:popbom/features/common/widget/comments_bottom_sheet.dart';
import 'package:popbom/features/profile/controller/follow_unfollow_contoller.dart';
import 'package:popbom/features/gift/controller/gift_controller.dart';
import 'package:popbom/features/profile/controller/post_action_controller.dart';
import 'package:popbom/features/profile/controller/profile_controller.dart';
import 'package:popbom/features/common/widget/share_sheet.dart';
import 'package:popbom/features/gift/widget/gift_item.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;
  final String username;
  final String avatarUrl;

  const UserProfileScreen({
    super.key,
    required this.userId,
    required this.username,
    required this.avatarUrl,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final UserPostsController postsController = Get.find<UserPostsController>();
  final giftC = Get.put(GiftController()); // <-- at top of State class

  XFile? _avatarFile;
  String _name = '';
  String _username = '';
  String _bio = '';
  String _instagram = '';
  String _youtube = '';
  bool _isFollowing = false;
  bool _loadingProfile = true;
  String _avatarUrl = '';

  int _followersCount = 0;
  int _followingCount = 0;

  final ImagePicker _picker = ImagePicker();
  final FollowUnfollowController _followController =
      Get.find<FollowUnfollowController>();

  @override
  void initState() {
    super.initState();
    giftC.loadGiftCounts(widget.userId);

    _username = widget.username;
    _avatarUrl = widget.avatarUrl;

    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _loadingProfile = true);

    await postsController.loadUserPosts(widget.userId);
    await postsController.loadTaggedPosts(widget.userId);
    postsController.generateThumbnailsInBackground();

    await Future.wait([
      postsController.fetchTotalReactions(widget.userId),
      _fetchAndApplyUser(),
    ]);


    setState(() => _loadingProfile = false);
  }

  Future<void> _fetchAndApplyUser() async {
    try {
      setState(() => _loadingProfile = true);

      final client = Get.find<NetworkClient>();

      final res = await client.getRequest(
        Urls.getUserProfileById(widget.userId),
      );

      if (!res.isSuccess) {
        setState(() => _loadingProfile = false);
        return;
      }

      final data = res.responseData?["data"] ?? {};

      setState(() {
        _name = data["name"] ?? "";
        _username = data["username"] ?? "";
        _bio = data["bio"] ?? "";
        _avatarUrl = data["photo"] ?? "";
      });

      // 2️⃣ FOLLOWERS LIST
      final followerRes = await client.getRequest(
        Urls.getFollowersUrl(widget.userId),
      );
      final followerList = followerRes.responseData?["data"] ?? [];

      // 3️⃣ FOLLOWING LIST
      final followingRes = await client.getRequest(
        Urls.getFollowingListUrl(widget.userId),
      );
      final followingList = followingRes.responseData?["data"] ?? [];

      setState(() {
        _followersCount = followerList.length;
        _followingCount = followingList.length;
      });

      // 4️⃣ CHECK IF I FOLLOW THIS USER
      _isFollowing = _followController.isFollowing(widget.userId);
    } catch (e) {
      debugPrint("Profile load error: $e");
    } finally {
      if (mounted) setState(() => _loadingProfile = false);
    }
  }

  Future<void> _pickAvatar() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null) return;
    setState(() {
      _avatarFile = file;
    });
    // TODO: upload avatarFile to server if needed
  }

  void _openInstagramView(
    List<Map<String, dynamic>> posts,
    String category,
    int startIndex,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InstagramFeedView(
          posts: posts,
          currentUsername: _username,
          currentAvatar: _avatarFile?.path ?? _avatarUrl,
          category: category,
          initialIndex: startIndex,
          profileUserId: widget.userId, // ⭐ ADD THIS
        ),
      ),
    );
  }

  double _gridHeight(BuildContext context, int count) {
    final width = MediaQuery.of(context).size.width - 32;
    final tileW = (width - 2 * 6) / 3;
    final tileH = tileW / 0.78;
    final rows = (count / 3).ceil();
    final gaps = max(0, rows - 1) * 6;
    return rows * tileH + gaps;
  }

  Future<void> _toggleFollow() async {
    final status = await _followController.toggleFollow(widget.userId);

    if (status != null) {
      setState(() {
        _isFollowing = (status == "follow");
      });

      _fetchAndApplyUser(); // refresh counts
    }
  }


  Future<void> _navigateToChat() async {
    final chatListC = Get.find<ChatListController>();

    if (chatListC.chatList.isEmpty) {
      await chatListC.loadChatList();
    }

    final existingChat = chatListC.chatList.firstWhereOrNull(
          (c) => c.friendId == widget.userId,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          chatId: existingChat?.chatId ?? "",
          friendId: widget.userId,
          friendName: _name.isNotEmpty ? _name : widget.username,
          friendImage: _avatarUrl,
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Builder(
      builder: (context) {
        return Scaffold(
          backgroundColor: cs.background,
          appBar: AppBar(
            backgroundColor: theme.appBarTheme.backgroundColor ?? cs.background,
            elevation: theme.appBarTheme.elevation ?? 0,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: theme.appBarTheme.foregroundColor ?? cs.onBackground,
                size: 18,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: Text(
              'Profile',
              style:
                  theme.appBarTheme.titleTextStyle ??
                  theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: cs.onBackground,
                  ),
            ),
          ),
          body: SafeArea(
            child: Stack(
              children: [
                RefreshIndicator(
                  onRefresh: () async {
                    await _loadAll();
                  },
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 6),
                        // Avatar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Material(
                                  shape: const CircleBorder(),
                                  color: Colors.transparent,
                                  child: CircleAvatar(
                                    radius: 45,
                                    backgroundColor: cs.surface,
                                    child: _avatarUrl.isNotEmpty
                                        ? ClipOval(
                                            child: CachedNetworkImage(
                                              imageUrl: _avatarUrl,
                                              width: 72,
                                              height: 72,
                                              memCacheHeight: 180,
                                              memCacheWidth: 180,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) =>
                                                  const CircularProgressIndicator(
                                                      strokeWidth: 2),
                                              errorWidget:
                                                  (context, url, error) {
                                                return Icon(
                                                  Icons.person,
                                                  size: 40,
                                                  color: cs.onSurface,
                                                );
                                              },
                                            ),
                                          )
                                        : Icon(
                                            Icons.person,
                                            size: 40,
                                            color: cs.onSurface,
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Username / name
                        Text(
                          _name.isNotEmpty ? _name : widget.username,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: cs.onBackground,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '@$_username',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 12.5,
                            color: cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_bio.isNotEmpty) ...[
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              _bio,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: cs.onBackground,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        // Stats (static placeholders — replace with real values if available)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _Stat(
                              label: 'Following',
                              value: '$_followingCount',
                            ),
                            const _Dot(),
                            _Stat(
                              label: 'Followers',
                              value: '$_followersCount',
                            ),
                            const _Dot(),
                            Obx(
                              () => _Stat(
                                label: 'Likes',
                                value: Get.find<UserPostsController>()
                                    .totalReactions
                                    .value
                                    .toString(),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),
                        // Follow and Message Buttons
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _GreenButton(
                                text: _isFollowing ? 'Following' : 'Follow',
                                onTap: _toggleFollow,
                              ),
                              _GreenButton(
                                text: 'Message',
                                onTap: _navigateToChat,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),
                        // Gifts
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Gifts',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: cs.onBackground,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: GiftItem(
                                label: "Coins",
                                emoji: "🪙",
                                count: giftC.coins.value,
                              ),
                            ),
                            Expanded(
                              child: GiftItem(
                                label: "Hearts",
                                emoji: "❤️",
                                count: giftC.hearts.value,
                              ),
                            ),
                            Expanded(
                              child: GiftItem(
                                label: "Roses",
                                emoji: "🌹",
                                count: giftC.roses.value,
                              ),
                            ),
                            Expanded(
                              child: GiftItem(
                                label: "Stars",
                                emoji: "⭐",
                                count: giftC.stars.value,
                              ),
                            ),
                            Expanded(
                              child: GiftItem(
                                label: "Fireworks",
                                emoji: "🔥",
                                count: giftC.fire.value,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        // Tabs
                        DefaultTabController(
                          length: 2,
                          child: Column(
                            children: [
                              TabBar(
                                labelColor: cs.onBackground,
                                unselectedLabelColor:
                                    theme.textTheme.bodyMedium?.color,
                                indicatorColor: cs.onBackground,
                                dividerColor: Colors.transparent,
                                tabs: [
                                  Tab(
                                    icon: SvgPicture.asset(
                                      'assets/icon/grid.svg',
                                      width: 22,
                                      height: 22,
                                      colorFilter: ColorFilter.mode(
                                        cs.onSurface,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                  Tab(
                                    icon: SvgPicture.asset(
                                      'assets/icon/tag.svg',
                                      width: 22,
                                      height: 22,
                                      colorFilter: ColorFilter.mode(
                                        cs.onSurface,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Builder(
                                builder: (ctx) {
                                  final h0 = _gridHeight(
                                    ctx,
                                    postsController.userPosts.length,
                                  );
                                  final h1 = _gridHeight(
                                    ctx,
                                    postsController.taggedPosts.length,
                                  );
                                  final tallest = [h0, h1].reduce(max);

                                  return // In the TabBarView section, replace the current _PostsGrid widgets with:
                                  SizedBox(
                                    height: tallest,
                                    child: TabBarView(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      children: [
                                        Obx(() {
                                          final apiPosts =
                                              postsController.userPosts;

                                          return _PostsGrid(
                                            posts: apiPosts.map((p) {
                                              return {
                                                'postId': p.id,
                                                'image': p.thumbnail ?? "",
                                                'isVideo': (p.videoUrl ?? "")
                                                    .isNotEmpty,
                                                'videoUrl': p.videoUrl ?? "",
                                                'caption': p.title,
                                                'authorUsername':
                                                    p.author?.username ??
                                                    _username,
                                                'authorPhoto':
                                                    p.author?.photo ??
                                                    _avatarUrl,
                                                'likeCount': p.likeCount,
                                                'commentCount': p.commentCount,
                                                'isLiked': p.isLiked,
                                                'isSaved': p.isSaved,
                                                'reactionId': p.reactionId,
                                                'views': p.watchCount,
                                                'taggedUsers': p.taggedUsers,
                                                'date': p.date,
                                                'category': 'posts',
                                              };
                                            }).toList(),

                                            onImageTap: (index) {
                                              final p = apiPosts[index];

                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => InstagramFeedView(
                                                    posts: apiPosts.map((e) {
                                                      final img = e.thumbnail ?? "";

                                                      String video = "";

                                                      if (e.videoUrl != null &&
                                                          e
                                                              .videoUrl!
                                                              .isNotEmpty) {
                                                        if (e.videoUrl!
                                                            .startsWith(
                                                              "http",
                                                            )) {
                                                          video = e.videoUrl!;
                                                        } else {
                                                          video =
                                                              "${Urls.baseUrl}/${e.videoUrl!}";
                                                        }
                                                      }

                                                      return {
                                                        'postId': e.id,
                                                        'image': img,
                                                        'isVideo':
                                                            video.isNotEmpty,
                                                        'videoUrl': video,
                                                        'caption':
                                                            e.title ?? "",
                                                        'username': _username,
                                                        'isLiked': e.isLiked,
                                                        'isSaved': e.isSaved,
                                                        'likeCount': e.likeCount ?? 0,
                                                        'commentCount': e.commentCount ?? 0,
                                                        'reactionId':
                                                            e.reactionId,
                                                        'category': "posts",
                                                        'views': e.watchCount,
                                                      };
                                                    }).toList(),

                                                    currentUsername: _username,
                                                    currentAvatar:
                                                        (_avatarFile != null &&
                                                            _avatarFile!
                                                                .path
                                                                .isNotEmpty)
                                                        ? _avatarFile!.path
                                                        : _avatarUrl,
                                                    category: "posts",
                                                    initialIndex: index,
                                                    profileUserId: widget
                                                        .userId, // ⭐ ADD THIS
                                                  ),
                                                ),
                                              );
                                            },

                                            category: 'posts',
                                          );
                                        }),

                                        Obx(() {
                                          final tagged =
                                              postsController.taggedPosts;

                                          return _PostsGrid(
                                            posts: tagged.map((e) {
                                              return {
                                                'postId': e.id,
                                                'image': e.thumbnail ?? "",
                                                'isVideo': (e.videoUrl ?? "").isNotEmpty,
                                                'videoUrl': e.videoUrl ?? "",
                                                'caption': e.title ?? "",

                                                // ✅ FLAT AUTHOR DATA (LIKE ProfileScreen)
                                                'username': e.author?.username ?? "",
                                                'userPhoto': e.author?.photo ?? "",

                                                'isLiked': e.isLiked,
                                                'isSaved': e.isSaved,
                                                'likeCount': e.likeCount,
                                                'commentCount': e.commentCount,
                                                'reactionId': e.reactionId,
                                                'views': e.watchCount,
                                                'taggedUsers': e.taggedUsers,
                                                'date': e.date ?? "",
                                                'category': "tagged",
                                              };
                                            }).toList(),
                                            onImageTap: (index) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      InstagramFeedView(
                                                        posts: tagged.map((e) {
                                                          return {
                                                            'postId': e.id,
                                                            'image': e.thumbnail ?? "",
                                                            'isVideo': (e.videoUrl ?? "").isNotEmpty,
                                                            'videoUrl': e.videoUrl ?? "",
                                                            'caption': e.title ?? "",

                                                            // ✅ SAME HERE
                                                            'username': e.author?.username ?? "",
                                                            'userPhoto': e.author?.photo ?? "",

                                                            'isLiked': e.isLiked,
                                                            'isSaved': e.isSaved,
                                                            'likeCount': e.likeCount ?? 0,
                                                            'commentCount': e.commentCount ?? 0,
                                                            'reactionId': e.reactionId,
                                                            'views': e.watchCount,
                                                            'category': "tagged",
                                                          };
                                                        }).toList(),
                                                        currentUsername:
                                                            _username,
                                                        currentAvatar:
                                                            (_avatarFile !=
                                                                    null &&
                                                                _avatarFile!
                                                                    .path
                                                                    .isNotEmpty)
                                                            ? _avatarFile!.path
                                                            : _avatarUrl,
                                                        category: "tagged",
                                                        initialIndex: index,
                                                        profileUserId: widget
                                                            .userId, // ⭐ ADD THIS
                                                      ),
                                                ),
                                              );
                                            },
                                            category: 'tagged',
                                          );
                                        }),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_loadingProfile)
                  Positioned.fill(
                    child: Container(
                      color: cs.background.withOpacity(0.6),
                      child: Center(child: CenteredCircularProgressIndicator()),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class InstagramFeedView extends StatefulWidget {
  final List<Map<String, dynamic>> posts;
  final String currentUsername;
  final String currentAvatar;
  final String category;
  final int initialIndex;
  final String profileUserId;

  const InstagramFeedView({
    super.key,
    required this.posts,
    required this.currentUsername,
    required this.currentAvatar,
    required this.category,
    required this.profileUserId,
    this.initialIndex = 0,
  });

  @override
  State<InstagramFeedView> createState() => _InstagramFeedViewState();
}

class _InstagramFeedViewState extends State<InstagramFeedView> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();

    ///  scroll to clicked post
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 50));

      if (!mounted) return;

      if (_scrollController.hasClients) {
        final double pos = widget.initialIndex * 520;
        _scrollController.jumpTo(pos);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _titleForCategory() {
    switch (widget.category) {
      case 'posts':
        return 'My Posts';
      default:
        return 'Tagged Posts';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor ?? cs.background,
        elevation: theme.appBarTheme.elevation ?? 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: theme.appBarTheme.foregroundColor ?? cs.onBackground,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _titleForCategory(),
          style:
              (theme.appBarTheme.titleTextStyle ??
                      theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ))!
                  .copyWith(
                    color: theme.appBarTheme.foregroundColor ?? cs.onBackground,
                  ),
        ),
        centerTitle: true,
      ),
      body: widget.posts.isEmpty
          ? Center(
              child: Text(
                'No posts yet',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ),
            )
          : ListView.builder(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: widget.posts.length,
              itemBuilder: (_, index) {
                return _InstagramPost(
                  post: widget.posts[index],
                  currentAvatar: widget.currentAvatar,
                  currentUsername: widget.currentUsername,
                  category: widget.category,
                  profileUserId: widget.profileUserId,
                );
              },
            ),
    );
  }
}

// Single Instagram Post Widget - NOW STATEFUL
class _InstagramPost extends StatefulWidget {
  final Map<String, dynamic> post;
  final String currentAvatar;
  final String currentUsername;
  final String category;
  final String profileUserId;

  const _InstagramPost({
    required this.post,
    required this.currentAvatar,
    required this.currentUsername,
    required this.category,
    required this.profileUserId,
  });

  @override
  State<_InstagramPost> createState() => __InstagramPostState();
}

class __InstagramPostState extends State<_InstagramPost> {
  final actionCtrl = Get.find<PostActionsController>();

  bool _isLiked = false;
  int _likeCount = 0;
  int _commentCount = 0;
  String? _reactionId;
  bool _isSaved = false;
  String? _savedRecordId;

  String get _postId {
    return widget.post['postId']?.toString() ??
        widget.post['_id']?.toString() ??
        widget.post['id']?.toString() ??
        "";
  }

  int get _currentViews {
    final posts = Get.find<UserPostsController>();

    final p =
        posts.userPosts.firstWhereOrNull((e) => e.id == _postId) ??
            posts.taggedPosts.firstWhereOrNull((e) => e.id == _postId);

    return p?.watchCount ?? widget.post['views'] ?? 0;
  }


  @override
  void initState() {
    super.initState();

    final posts = Get.find<UserPostsController>();

    final p =
        posts.userPosts.firstWhereOrNull((e) => e.id == _postId) ??
            posts.taggedPosts.firstWhereOrNull((e) => e.id == _postId);

    _isLiked = p?.isLiked ?? widget.post['isLiked'] ?? false;
    _reactionId = p?.reactionId ?? widget.post['reactionId'];
    _isSaved = p?.isSaved ?? widget.post['isSaved'] ?? false;

    _likeCount = p?.likeCount ?? widget.post['likeCount'] ?? 0;
    _commentCount = p?.commentCount ?? widget.post['commentCount'] ?? 0;
  }


  Widget _buildImage(String url) {
    if (url.startsWith("/") || url.startsWith("file://")) {
      return Image.file(
        File(url.replaceAll("file://", "")),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            const Center(child: Icon(Icons.error, color: Colors.white)),
      );
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) =>
          const Center(child: Icon(Icons.error, color: Colors.white)),
    );
  }

  void _toggleLike() async {
    final postId = _postId;
    if (postId.isEmpty) return;

    final newState = !_isLiked;

    setState(() {
      _isLiked = newState;
      _likeCount += newState ? 1 : -1;
    });

    final profile = Get.find<UserPostsController>();
    final index = profile.userPosts.indexWhere((p) => p.id == postId);

    bool success = false;

    if (newState) {
      final reactionId = await actionCtrl.toggleLike(
        postId: postId,
        isLikedNow: true,
      );

      if (reactionId != null) {
        _reactionId = reactionId;

        final posts = Get.find<UserPostsController>();
        final idx = posts.userPosts.indexWhere((p) => p.id == postId);

        if (idx != -1) {
          posts.userPosts[idx].isLiked = true;
          posts.userPosts[idx].reactionId = reactionId;
          posts.userPosts.refresh();
        }

        success = true;
      }
    }
    else {
      // 💔 UNLIKE
      if (_reactionId == null) {
        final r = await actionCtrl.getReactionByPostId(postId);
        _reactionId = r?['_id'];
      }

      if (_reactionId != null) {
        success = await actionCtrl.removeReaction(_reactionId!);

        if (success) {
          if (index != -1) {
            profile.userPosts[index].isLiked = false;
            profile.userPosts[index].reactionId = null;
            profile.userPosts.refresh();
          }
          _reactionId = null;
        }
      }
    }

    if (!success) {
      setState(() {
        _isLiked = !_isLiked;
        _likeCount += _isLiked ? 1 : -1;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to update like")));
    }

    Get.find<UserPostsController>().fetchTotalReactions(widget.profileUserId);
  }

  void _toggleSave() async {
    final postId = _postId;

    final result = await actionCtrl.toggleSave(
      postId: postId,
      isCurrentlySaved: _isSaved,
    );

    if (result == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to update save")));
      return;
    }

    setState(() {
      _isSaved = result["isSaved"];
      _savedRecordId = result["savedRecordId"];
    });

    // Refresh saved list
    Get.find<ProfileController>().fetchSavedPosts();
  }

  void _openComments() {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return CommentsBottomSheet(
          commentCount: _commentCount,
          postId: _postId,

          // When new comment is added from bottom sheet
          onSendComment: (String text) async {
            if (text.trim().isEmpty) return;

            final postId = _postId;
            if (postId.isEmpty) return;

            final success = await actionCtrl.createComment(
              postId: postId,
              comment: text.trim(),
            );

            if (success) {
              // Update UI and parent lists
              setState(() {
                _commentCount++;
              });

              final profile = Get.find<UserPostsController>();
              final i = profile.userPosts.indexWhere((p) => p.id == postId);
              if (i != -1) {
                profile.userPosts[i].commentCount =
                    (profile.userPosts[i].commentCount ?? 0) + 1;
                profile.userPosts.refresh();
              }

              Navigator.pop(ctx);

              if (mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text("Comment added")));
              }
            } else {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Failed to send comment")),
                );
              }
            }
          },

          onCommentCountChanged: (newCount) {
            setState(() {
              _commentCount = newCount;
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final image = widget.post['image'] ?? "";
    final isVideo = widget.post['isVideo'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // 👤 Avatar (clickable only for tagged posts)
                GestureDetector(
                  onTap: widget.category == 'tagged'
                      ? () {
                    final userId = widget.post['userId'];
                    if (userId == null) return;

                    Get.to(
                          () => UserProfileScreen(
                        userId: userId,
                        username: widget.post['username'] ?? "",
                        avatarUrl: widget.post['userPhoto'] ?? "",
                      ),
                    );
                  }
                      : null,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundImage:
                    (widget.category == 'posts'
                        ? widget.currentAvatar
                        : widget.post['userPhoto']) != null &&
                        (widget.category == 'posts'
                            ? widget.currentAvatar
                            : widget.post['userPhoto'])
                            .toString()
                            .isNotEmpty
                        ? NetworkImage(
                      widget.category == 'posts'
                          ? widget.currentAvatar
                          : widget.post['userPhoto'],
                    )
                        : null,
                    child:
                    ((widget.category == 'posts'
                        ? widget.currentAvatar
                        : widget.post['userPhoto']) ??
                        "")
                        .isEmpty
                        ? const Icon(Icons.person, size: 16)
                        : null,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // 👤 Username (clickable only for tagged posts)
                          GestureDetector(
                            onTap: widget.category == 'tagged'
                                ? () {
                              final userId = widget.post['userId'];
                              if (userId == null) return;

                              Get.to(
                                    () => UserProfileScreen(
                                  userId: userId,
                                  username: widget.post['username'] ?? "",
                                  avatarUrl: widget.post['userPhoto'] ?? "",
                                ),
                              );
                            }
                                : null,
                            child: Text(
                              widget.category == 'posts'
                                  ? widget.currentUsername
                                  : (widget.post['username'] ?? ''),
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: cs.onBackground,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // 🏷 Tagged users line
                      if (widget.category == 'tagged') ...[
                        const SizedBox(height: 2),
                        Text(
                          'Tagged ${(widget.post['taggedUsers'] as List?)?.join(', ') ?? ''}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Post Image/Video
          SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.width,
            child: isVideo
                ? _VideoPlayerInline(
                    url: widget.post['videoUrl'] ?? "",
                    postId:
                        widget.post['postId']?.toString() ??
                        widget.post['_id']?.toString() ??
                        widget.post['id']?.toString() ??
                        "",
                  )
                : _buildImage(image),
          ),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _isLiked ? Icons.favorite : Icons.favorite_border,
                        size: 28,
                        color: _isLiked ? Colors.red : Colors.white,
                      ),
                      onPressed: _toggleLike,
                    ),
                    InkWell(
                      onTap: _openComments,
                      borderRadius: BorderRadius.circular(20),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icon/comment.svg',
                            width: 22,
                            height: 22,
                            colorFilter: ColorFilter.mode(
                              Theme.of(context).colorScheme.onSurface,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '$_commentCount',
                            style: TextStyle(color: cs.onSurface),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: SvgPicture.asset(
                        'assets/icon/share.svg',
                        width: 22,
                        height: 22,
                        colorFilter: ColorFilter.mode(
                          Theme.of(context).colorScheme.onSurface,
                          BlendMode.srcIn,
                        ),
                      ),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => ShareSheet(
                            shareText: "Check out this post!",
                            shareLink: "https://popbom.app/post/$_postId",
                            postId: _postId,
                            videoUrl: widget.post['videoUrl'],
                          ),
                        );
                      },
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(
                    _isSaved ? Icons.bookmark : Icons.bookmark_border,
                    size: 28,
                    color: _isSaved ? cs.primary : cs.onSurface,
                  ),
                  onPressed: _toggleSave,
                ),
              ],
            ),
          ),

          // Likes
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Liked by $_likeCount people',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: cs.onBackground,
              ),
            ),
          ),

          // Caption
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: widget.category == 'posts'
                        ? widget.currentUsername
                        : (widget.post['username'] ?? ""),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: cs.onBackground,
                      fontSize: 14,
                    ),
                  ),
                  TextSpan(
                    text:
                        (widget.post['caption'] ?? widget.post['title'] ?? ""),
                    style: TextStyle(color: cs.onBackground, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),

          // Date
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              (widget.post['date'] ?? ""),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodyMedium?.color,
                fontSize: 12,
              ),
            ),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// Posts Grid with different categories
class _PostsGrid extends StatelessWidget {
  final List<Map<String, dynamic>> posts;
  final Function(int) onImageTap; // Changed from VoidCallback to Function(int)
  final String category;

  const _PostsGrid({
    required this.posts,
    required this.onImageTap,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return _PostTile(
          imageUrl: post['image'],
          views: post["views"] ?? 0,
          onTap: () => onImageTap(index),
          // Pass the index
          isVideo: post['isVideo'] == true,
          category: category,
        );
      },
    );
  }
}

class _PostTile extends StatelessWidget {
  final String imageUrl;
  final int views;
  final VoidCallback onTap;
  final bool isVideo;
  final String category;

  const _PostTile({
    required this.imageUrl,
    required this.views,
    required this.onTap,
    this.isVideo = false,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    bool _isLocalFile(String url) {
      return url.startsWith("/") || url.startsWith("file://");
    }

    Widget _loadImage(String url) {
      if (_isLocalFile(url)) {
        return Image.file(
          File(url.replaceAll("file://", "")),
          fit: BoxFit.cover,
        );
      }
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            const Center(child: Icon(Icons.error, color: Colors.white)),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _loadImage(imageUrl),

            if (isVideo)
              const Positioned(
                top: 4,
                right: 4,
                child: Icon(Icons.play_arrow, color: Colors.white, size: 16),
              ),
            Positioned(
              left: 6,
              bottom: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                color: Colors.black54,
                child: Row(
                  children: [
                    Icon(
                      isVideo
                          ? Icons.play_arrow
                          : Icons.remove_red_eye_outlined,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$views views',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            if (category == 'saved')
              const Positioned(
                top: 4,
                left: 4,
                child: Icon(Icons.bookmark, color: Colors.white, size: 16),
              ),
            if (category == 'tagged')
              const Positioned(
                top: 4,
                left: 4,
                child: Icon(Icons.person, color: Colors.white, size: 16),
              ),
          ],
        ),
      ),
    );
  }
}

class _SheetItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const _SheetItem({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: theme.iconTheme.color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: cs.onSurface,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: theme.iconTheme.color),
          ],
        ),
      ),
    );
  }
}

class _GreenButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final bool isLoading;

  const _GreenButton({
    super.key,
    required this.text,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 130,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: const LinearGradient(
            colors: [Color(0xff21E6A0), Color(0xFF6DF844)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Center(
          child: isLoading
              ? CenteredCircularProgressIndicator()
              : Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}

class _GiftLabel extends StatelessWidget {
  final String text;
  final String emoji;

  const _GiftLabel({required this.text, required this.emoji});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Row(
      children: [
        Text(
          text,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 12,
            color: cs.onBackground,
          ),
        ),
        const SizedBox(width: 4),
        Text(emoji),
      ],
    );
  }
}

class _GiftCount extends StatelessWidget {
  final String value;

  const _GiftCount(this.value);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      value,
      style: TextStyle(fontWeight: FontWeight.w600, color: cs.onBackground),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;

  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: cs.onBackground,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: cs.onSurface,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text('•', style: TextStyle(color: cs.onBackground)),
    );
  }
}

void _openShareSheet(BuildContext context, String link) {
  final cs = Theme.of(context).colorScheme;
  final text = 'Check this out: $link';

  Future<void> _shareToWhatsApp() async {
    final uri = Uri.parse('whatsapp://send?text=${Uri.encodeComponent(text)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      await Share.share(text);
    }
  }

  Future<void> _openWhatsAppStatus() async {
    final uri = Uri.parse('whatsapp://');
    await _openExternal(uri);
  }

  Future<void> _shareToSms() async {
    final uri = Uri.parse('sms:?body=${Uri.encodeComponent(text)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      await Share.share(text);
    }
  }

  Future<void> _shareToMessenger() async {
    final uri = Uri.parse(
      'fb-messenger://share?link=${Uri.encodeComponent(link)}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      await Share.share(text);
    }
  }

  Future<void> _openInstagram() async {
    final insta = Uri.parse('instagram://app');
    if (await canLaunchUrl(insta)) {
      await launchUrl(insta, mode: LaunchMode.externalApplication);
    } else {
      await _openExternal(Uri.parse('https://www.instagram.com/'));
    }
  }

  showModalBottomSheet(
    context: context,
    backgroundColor: cs.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      final topItems = [
        _ShareCircle(
          svgAsset: 'assets/icon/whatsapp.svg',
          label: 'WhatsApp',
          onTap: _shareToWhatsApp,
          tileWidth: 100,
          outerDiameter: 70,
          iconBox: 40,
        ),
        _ShareCircle(
          svgAsset: 'assets/icon/whatsapp.svg',
          label: 'WhatsApp\nstatus',
          onTap: _openWhatsAppStatus,
          tileWidth: 100,
          outerDiameter: 70,
          iconBox: 40,
        ),
        _ShareCircle(
          svgAsset: 'assets/icon/Message.svg',
          label: 'Message',
          onTap: () => Share.share(text, subject: 'Share'),
          tileWidth: 100,
          outerDiameter: 70,
          iconBox: 40,
        ),
        _ShareCircle(
          svgAsset: 'assets/icon/sms_logo.svg',
          label: 'SMS',
          onTap: _shareToSms,
          tileWidth: 100,
          outerDiameter: 70,
          iconBox: 40,
        ),
        _ShareCircle(
          svgAsset: 'assets/icon/messenger_logo.svg',
          label: 'Messenger',
          onTap: _shareToMessenger,
          tileWidth: 100,
          outerDiameter: 70,
          iconBox: 40,
        ),
        _ShareCircle(
          svgAsset: 'assets/icon/Instagram_logo.svg',
          label: 'Instagram',
          onTap: _openInstagram,
          tileWidth: 100,
          outerDiameter: 70,
          iconBox: 40,
        ),
      ];

      final bottomItems = [
        _ShareCircle(
          svgAsset: 'assets/icon/report_logo.svg',
          label: 'Report',
          background: cs.surfaceVariant,
          darkIcon: true,
          onTap: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Reported')));
          },
        ),
        _ShareCircle(
          svgAsset: 'assets/icon/broken_heart_icon.svg',
          label: 'Not interested',
          background: cs.surfaceVariant,
          darkIcon: true,
          onTap: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('We will show fewer like this')),
            );
          },
        ),
        _ShareCircle(
          svgAsset: 'assets/icon/download_icon.svg',
          label: 'Save video',
          background: cs.surfaceVariant,
          darkIcon: true,
          onTap: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Saved')));
          },
        ),
        _ShareCircle(
          svgAsset: 'assets/icon/duet.svg',
          label: 'Duet',
          background: cs.surfaceVariant,
          darkIcon: true,
          onTap: () => Navigator.pop(context),
        ),
        _ShareCircle(
          svgAsset: 'assets/icon/react_icon.svg',
          label: 'React',
          background: cs.surfaceVariant,
          darkIcon: true,
          onTap: () => Navigator.pop(context),
        ),
        _ShareCircle(
          svgAsset: 'assets/icon/bookmark_icon.svg',
          label: 'Add to\nFavorites',
          background: cs.surfaceVariant,
          darkIcon: true,
          onTap: () {
            Navigator.pop(context);
            // TODO: favorite toggle
          },
        ),
      ];

      Row buildRow(List<Widget> items) => Row(
        children: items
            .map((w) => Expanded(child: Center(child: w)))
            .toList(growable: false),
      );

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Share to',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              buildRow(topItems),
              const SizedBox(height: 18),
              buildRow(bottomItems),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> _shareToWhatsApp(BuildContext context, String link) async {
  final uri = Uri.parse('whatsapp://send?text=${Uri.encodeComponent(link)}');
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    _shareGeneric(context, link);
    _toast(context, 'WhatsApp not installed, used system share');
  }
}

Future<void> _shareToSms(BuildContext context, String link) async {
  final uri = Uri.parse('sms:?body=${Uri.encodeComponent(link)}');
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    _shareGeneric(context, link);
  }
}

Future<void> _shareGeneric(BuildContext context, String link) async {
  await Share.share(link);
}

void _toast(BuildContext context, String msg) {
  final cs = Theme.of(context).colorScheme;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(msg, style: TextStyle(color: cs.onInverseSurface)),
        backgroundColor: cs.inverseSurface,
      ),
    );
}

class _ShareCircle extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final String? svgAsset;
  final IconData? icon;
  final Color? background;
  final bool darkIcon;
  final Color? labelColor;

  final double tileWidth;
  final double outerDiameter;
  final double iconBox;

  const _ShareCircle({
    required this.label,
    required this.onTap,
    this.svgAsset,
    this.icon,
    this.background,
    this.darkIcon = false,
    this.labelColor,
    this.tileWidth = 78,
    this.outerDiameter = 56,
    this.iconBox = 26,
  });

  static const double _gap = 6;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget iconWidget;
    if (svgAsset != null) {
      iconWidget = SizedBox(
        width: iconBox,
        height: iconBox,
        child: FittedBox(
          fit: BoxFit.contain,
          alignment: Alignment.center,
          child: SvgPicture.asset(
            svgAsset!,
            colorFilter: darkIcon
                ? ColorFilter.mode(cs.onSurface, BlendMode.srcIn)
                : null,
          ),
        ),
      );
    } else {
      iconWidget = SizedBox(
        width: iconBox,
        height: iconBox,
        child: FittedBox(
          fit: BoxFit.contain,
          alignment: Alignment.center,
          child: Icon(
            icon ?? Icons.circle,
            color: darkIcon ? cs.onSurface : Colors.white,
          ),
        ),
      );
    }

    return SizedBox(
      width: tileWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onTap: () {
              Navigator.pop(context);
              onTap();
            },
            customBorder: const CircleBorder(),
            child: Ink(
              width: outerDiameter,
              height: outerDiameter,
              decoration: BoxDecoration(
                color: background ?? cs.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Center(child: iconWidget),
            ),
          ),
          const SizedBox(height: _gap),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 28),
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              strutStyle: const StrutStyle(
                forceStrutHeight: true,
                height: 1.2,
                leading: 0.0,
                fontSize: 11,
              ),
              style: TextStyle(fontSize: 11, color: labelColor ?? cs.onSurface),
              textHeightBehavior: const TextHeightBehavior(
                applyHeightToFirstAscent: false,
                applyHeightToLastDescent: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _openExternal(Uri uri) async {
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _VideoPlayerInline extends StatefulWidget {
  final String url;
  final String postId;

  const _VideoPlayerInline({required this.url, required this.postId});

  @override
  State<_VideoPlayerInline> createState() => _VideoPlayerInlineState();
}

class _VideoPlayerInlineState extends State<_VideoPlayerInline> {
  late VideoPlayerController controller;
  bool isReady = false;

  @override
  void initState() {
    super.initState();

    String videoUrl = widget.url.trim();

    if (!videoUrl.startsWith("http")) {
      videoUrl = "${Urls.baseUrl}/$videoUrl";
    }

    print("🎬 PLAYING VIDEO FROM: $videoUrl");
    print("raw video url : ${videoUrl}");

    controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));

    controller.initialize().then((_) async {
      if (!mounted) return;

      // ❗ aspectRatio fix
      if (controller.value.aspectRatio == 0 ||
          controller.value.aspectRatio.isNaN) {
        // force a default ratio (square)
        controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      }

      setState(() => isReady = true);
      controller.play();
      controller.setLooping(true);

      await _increaseViewCount();
    });
  }

  Future<void> _increaseViewCount() async {
    try {
      final posts = Get.find<UserPostsController>();
      final newCount = await posts.incrementWatchCount(widget.postId);

      if (newCount != null) {
        /// update in user posts
        final idx = posts.userPosts.indexWhere((p) => p.id == widget.postId);
        if (idx != -1) {
          posts.userPosts[idx].watchCount = newCount;
          posts.userPosts[idx].views = newCount;
          posts.userPosts.refresh();
        }

        /// update in tagged posts
        final tIdx = posts.taggedPosts.indexWhere((p) => p.id == widget.postId);
        if (tIdx != -1) {
          posts.taggedPosts[tIdx].watchCount = newCount;
          posts.taggedPosts.refresh();
        }
      }
    } catch (e) {
      print("⚠ Failed to update view count: $e");
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
        child: Center(child: CenteredCircularProgressIndicator()),
      );
    }

    return AspectRatio(
      aspectRatio:
          controller.value.aspectRatio == 0 ||
              controller.value.aspectRatio.isNaN
          ? 1
          : controller.value.aspectRatio,
      child: VideoPlayer(controller),
    );
  }
}
