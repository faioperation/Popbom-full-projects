import 'dart:io';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:popbom/app/urls.dart';
import 'package:popbom/features/common/ui/screen/app_shell.dart';
import 'package:popbom/features/profile/controller/follow_unfollow_contoller.dart';
import 'package:popbom/features/gift/controller/gift_controller.dart';
import 'package:popbom/features/profile/controller/profile_controller.dart';
import 'package:popbom/features/profile/controller/update_photo_controller.dart';
import 'package:popbom/features/profile/screen/add_friend_screen.dart';
import 'package:popbom/features/profile/screen/edit_profile_screen.dart';
import 'package:popbom/features/profile/widgets/insta_post_grid.dart';
import 'package:popbom/features/qrcode/screen/qr_code_screen.dart';
import 'package:popbom/features/rank/screen/rank_screen.dart';
import 'package:popbom/features/profile/screen/studio_screen.dart';
import 'package:popbom/features/gift/widget/gift_item.dart';
import 'package:popbom/features/settings/screen/settings_screen.dart';
import 'package:share_plus/share_plus.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key,this.onBack});
  final VoidCallback? onBack;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with AutomaticKeepAliveClientMixin{
  final ProfileController _profileController = Get.find<ProfileController>();
  final _updatePhotoController = Get.find<UpdatePhotoController>();
  final giftC = Get.find<GiftController>();

  final FollowUnfollowController followUnfollowController =
      Get.find<FollowUnfollowController>();

  @override
  bool get wantKeepAlive => true;


  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _profileController.loadProfileOnce();
      await followUnfollowController.refreshFollowing();
    });
  }

  XFile? _avatarFile;

  String _name = '';
  String _username = '';
  String _bio = '';
  String _instagram = '';
  String _youtube = '';

  Future<void> _pickAvatar() async {
    final ImagePicker picker = ImagePicker();
    final XFile? img = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (img == null || !mounted) return;

    final file = File(img.path);

    final success = await _updatePhotoController.updateProfilePhoto(file);

    if (success) {
      await _profileController.fetchMyProfile();
      setState(() {
        _avatarFile = img;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Profile photo updated!")));
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _updatePhotoController.errorMessage ?? "Failed to update photo",
          ),
        ),
      );
    }
  }

  void _goHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AppShell()),
          (route) => false,
    );
  }

  void _openMenuSheet() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // _SheetItem(
              //   icon: Icons.account_balance_wallet_outlined,
              //   title: 'Balance',
              //   onTap: () {
              //     Navigator.pop(sheetContext);
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(builder: (_) => const BalanceScreen()),
              //     );
              //   },
              // ),
              _SheetItem(
                icon: Icons.qr_code_2_outlined,
                title: 'Your QR code',
                onTap: () {
                  Navigator.pop(sheetContext);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const QrCodeScreen()),
                  );
                },
              ),
              _SheetItem(
                icon: Icons.video_camera_back_outlined,
                title: 'Studio',
                onTap: () {
                  Navigator.pop(sheetContext);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const StudioScreen()),
                  );
                },
              ),
              _SheetItem(
                icon: Icons.emoji_events_outlined,
                title: 'Rank',
                onTap: () {
                  Navigator.pop(sheetContext);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => RankScreen()),
                  );
                },
              ),
              _SheetItem(
                icon: Icons.settings_outlined,
                title: 'Settings & Privacy',
                onTap: () {
                  Navigator.pop(sheetContext);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return GetBuilder<ProfileController>(
      builder: (controller) {
        if (controller.isLoading || controller.user == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = controller.user!;

        // API DATA → LOCAL VARIABLES
        _name = user.name ?? "";
        _username = user.username ?? '';
        _bio = user.bio ?? '';
        _instagram = user.instaLink ?? "";
        _youtube = user.youtubeLink ?? "";

        return Scaffold(
          backgroundColor: cs.background,
          appBar: AppBar(
            backgroundColor: theme.appBarTheme.backgroundColor ?? cs.background,
            elevation: theme.appBarTheme.elevation ?? 0,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: cs.onBackground, size: 18),
              onPressed: () {
                if (widget.onBack != null) {
                  widget.onBack!();
                } else {
                  _goHome(context);
                }
              },
            ),
            title: Text(
              'Profile',
              style:
                  theme.appBarTheme.titleTextStyle ??
                  theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onBackground,
                    fontSize: 16
                  ),
            ),
            actions: [
              IconButton(
                onPressed: _openMenuSheet,
                icon: Icon(
                  Icons.menu,
                  color: theme.appBarTheme.foregroundColor ?? cs.onBackground,
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: ()async{
                final userId = _profileController.user?.id;

                if (userId != null) {
                  await _profileController.fetchMyProfile();
                  await _profileController.fetchTotalReactions(userId);
                  await _profileController.fetchMyPosts();
                  await _profileController.fetchTaggedPosts(userId);
                  await _profileController.fetchSavedPosts();
                  await followUnfollowController.refreshFollowing();
                }
              },
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: _pickAvatar,
                                child: CircleAvatar(
                                  radius: 45,
                                  backgroundColor: cs.surface,

                                  backgroundImage:
                                      (() {
                                            if (_avatarFile != null) {
                                              return FileImage(
                                                File(_avatarFile!.path),
                                              );
                                            }

                                            final photoUrl =
                                                _profileController.user?.photo;
                                            if (photoUrl != null &&
                                                photoUrl.isNotEmpty) {
                                              return CachedNetworkImageProvider(
                                                  photoUrl,
                                                  maxHeight: 180,
                                                  maxWidth: 180);
                                            }

                                            return null; // default icon used
                                          })()
                                          as ImageProvider<Object>?,

                                  // DEFAULT ICON
                                  child: (() {
                                    if (_avatarFile != null) return null;

                                    final photoUrl =
                                        _profileController.user?.photo;
                                    if (photoUrl != null && photoUrl.isNotEmpty)
                                      return null;

                                    return Icon(
                                      Icons.person,
                                      size: 40,
                                      color: cs.onSurface.withOpacity(0.5),
                                    );
                                  })(),
                                ),
                              ),
                            ),
                            Positioned(
                              right: -2,
                              bottom: -2,
                              child: GestureDetector(
                                onTap: _pickAvatar,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: cs.surface,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: cs.surface,
                                      width: 2,
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    backgroundColor: cs.primary,
                                    radius: 12,
                                    child: const Icon(
                                      Icons.add,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    Text(
                      _name,
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
                        color: theme.textTheme.bodyMedium?.color,
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

                    // Stats
                    Obx(
                      () => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _Stat(
                            label: 'Following',
                            value: followUnfollowController.followingCount.value
                                .toString(),
                          ),
                          const _Dot(),
                          _Stat(
                            label: 'Followers',
                            value: followUnfollowController.followersCount.value
                                .toString(),
                          ),
                          const _Dot(),
                          Obx(
                            () => _Stat(
                              label: 'Likes',
                              value: _profileController.totalReactions.value
                                  .toString(),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: _GreenButton(
                            text: 'Edit Profile',
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditProfileScreen(
                                    initialName: _name,
                                    initialUsername: _username,
                                    initialBio: _bio,
                                    initialInstagram: _instagram,
                                    initialYoutube: _youtube,
                                    initialAvatarPath: _avatarFile?.path,
                                  ),
                                ),
                              );

                              if (result != null) {
                                await _profileController.fetchMyProfile();
                              }

                              if (result != null && mounted) {
                                setState(() {
                                  _name = result['name'] ?? _name;
                                  _username = result['username'] ?? _username;
                                  _bio = result['bio'] ?? _bio;
                                  _instagram = result['instagram'] ?? _instagram;
                                  _youtube = result['youtube'] ?? _youtube;
                                  final p = result['avatarPath'] as String?;
                                  if (p != null && p.isNotEmpty) {
                                    _avatarFile = XFile(p);
                                  }
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _GreenButton(
                            text: 'Add Friends',
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AddFriendsScreen(),
                                ),
                              );
                              await followUnfollowController.refreshFollowing();
                              setState(() {});
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _GreenButton(
                            text: 'Share profile',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const QrCodeScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
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
                        Expanded(child: GiftItem(label: "Coins", emoji: "🪙", count: giftC.coins.value)),
                        Expanded(child: GiftItem(label: "Hearts", emoji: "❤️", count: giftC.hearts.value)),
                        Expanded(child: GiftItem(label: "Roses", emoji: "🌹", count: giftC.roses.value)),
                        Expanded(child: GiftItem(label: "Stars", emoji: "⭐", count: giftC.stars.value)),
                        Expanded(child: GiftItem(label: "Fireworks", emoji: "🔥", count: giftC.fire.value)),
                      ],
                    ),


                    const SizedBox(height: 18),

                    // Tabs
                    DefaultTabController(
                      length: 3,
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
                                    Theme.of(context).colorScheme.onSurface,
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
                                    Theme.of(context).colorScheme.onSurface,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                              Tab(
                                icon: SvgPicture.asset(
                                  'assets/icon/bookmark_icon.svg',
                                  width: 22,
                                  height: 22,
                                  colorFilter: ColorFilter.mode(
                                    Theme.of(context).colorScheme.onSurface,
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
                                _profileController.myPosts.length,
                              );
                              final h1 = _gridHeight(
                                ctx,
                                _profileController.taggedPosts.length,
                              );
                              final h2 = _gridHeight(
                                ctx,
                                _profileController.savedPosts.length,
                              );
                              final tallest = [h0, h1, h2].reduce(max);

                              return // In the TabBarView section, replace the current _PostsGrid widgets with:
                              SizedBox(
                                height: tallest,
                                child: TabBarView(
                                  physics: const NeverScrollableScrollPhysics(),
                                  children: [
                                    Obx(() {
                                      final apiPosts = _profileController.myPosts;

                                      return _PostsGrid(
                                        posts: apiPosts.map((p) {
                                          return {
                                            'postId': p.id,
                                            'image': p.thumbnail ?? "",
                                            'isVideo':
                                                p.videoUrl != null &&
                                                p.videoUrl!.isNotEmpty,
                                            'videoUrl': p.videoUrl ?? "",
                                            'caption': p.title ?? "",
                                            'username': _username,
                                            'isLiked': p.isLiked,
                                            'isSaved': p.isSaved,
                                            'likeCount': p.likeCount,
                                            'commentCount': p.commentCount,
                                            'reactionId': p.reactionId,
                                            'category': 'posts',
                                            'views': p.watchCount,
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
                                                      e.videoUrl!.isNotEmpty) {
                                                    if (e.videoUrl!.startsWith(
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
                                                    'isVideo': video.isNotEmpty,
                                                    'videoUrl': video,
                                                    'caption': e.title ?? "",
                                                    'username': _username,

                                                    'authorId': {
                                                      '_id': _profileController.user?.id,
                                                    },

                                                    'likeCount': e.likeCount ?? 0,
                                                    'commentCount': e.commentCount ?? 0,
                                                    'isLiked': e.isLiked,
                                                    'isSaved': e.isSaved,
                                                    'reactionId': e.reactionId,
                                                    'category': "posts",
                                                  };
                                                }).toList(),

                                                currentUsername: _username,
                                                currentAvatar:
                                                    _avatarFile?.path ??
                                                    user.photo ??
                                                    "",
                                                category: "posts",
                                                initialIndex: index,
                                              ),
                                            ),
                                          );
                                        },

                                        category: 'posts',
                                      );
                                    }),

                                    Obx(() {
                                      final tagged = _profileController.taggedPosts;

                                      return _PostsGrid(
                                        posts: tagged.map((e) {
                                          final img = e.thumbnail ?? "";
                                          return {
                                            'postId': e.id,
                                            'image': e.thumbnail ?? "",
                                            'isVideo': (e.videoUrl ?? "").isNotEmpty,
                                            'videoUrl': e.videoUrl ?? "",
                                            'caption': e.title ?? "",

                                            /// ✔ REAL owner username + photo
                                            'username': e.author?.username ?? "",
                                            'userPhoto': e.author?.photo ?? "",

                                            'isLiked': e.isLiked,
                                            'isSaved': e.isSaved,
                                            'likeCount': e.likeCount,
                                            'commentCount': e.commentCount,
                                            'reactionId': e.reactionId,

                                            'views': e.watchCount,
                                            'category': "tagged",
                                          };
                                        }).toList(),
                                        onImageTap: (index) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => InstagramFeedView(
                                                posts: tagged.map((e) {
                                                  return {
                                                    'postId': e.id,
                                                    'image': e.thumbnail ?? "",
                                                    'isVideo': (e.videoUrl ?? "").isNotEmpty,
                                                    'videoUrl': e.videoUrl ?? "",
                                                    'caption': e.title ?? "",

                                                    /// ✔ Real owner info passed to post viewer
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
                                                currentUsername: _username,
                                                currentAvatar: _avatarFile?.path ?? user.photo ?? "",
                                                category: "tagged",
                                                initialIndex: index,
                                              ),
                                            ),
                                          );
                                        },
                                        category: 'tagged',
                                      );
                                    }),


                                    Obx(() {
                                      final saved = _profileController.savedPosts;

                                      return _PostsGrid(
                                        posts: saved.map((e) {
                                          final img = e.thumbnail ?? "";
                                          return {
                                            'postId': e.id,
                                            'savedRecordId': e.savedRecordId,
                                            // ⭐ REQUIRED
                                            'image': e.thumbnail ?? "",
                                            'isVideo':
                                                (e.videoUrl ?? "").isNotEmpty,
                                            'videoUrl': e.videoUrl ?? "",
                                            'caption': e.title ?? "",
                                            'username': e.author?.username ?? "",
                                            'userPhoto': e.author?.photo ?? "",                                            'isLiked': e.isLiked,
                                            'isSaved': true,
                                            'likeCount': e.likeCount,
                                            'commentCount': e.commentCount,
                                            'reactionId': e.reactionId,
                                            'views': e.watchCount,
                                            'category': 'saved',
                                          };
                                        }).toList(),

                                        onImageTap: (index) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => InstagramFeedView(
                                                posts: saved.map((e) {
                                                  return {
                                                    'postId': e.id,
                                                    'savedRecordId':
                                                        e.savedRecordId,
                                                    // ⭐ REQUIRED
                                                    'image': e.thumbnail ?? "",
                                                    'isVideo': (e.videoUrl ?? "")
                                                        .isNotEmpty,
                                                    'videoUrl': e.videoUrl ?? "",
                                                    'caption': e.title ?? "",
                                                    'username': e.author?.username ?? "",
                                                    'userPhoto': e.author?.photo ?? "",
                                                    'isLiked': e.isLiked,
                                                    'isSaved': true,
                                                    'likeCount': e.likeCount ?? 0,
                                                    'commentCount': e.commentCount ?? 0,
                                                    'reactionId': e.reactionId,
                                                    'views': e.watchCount,
                                                    'category': "saved",
                                                  };
                                                }).toList(),

                                                currentUsername: _username,
                                                currentAvatar:
                                                    _avatarFile?.path ??
                                                    user.photo ??
                                                    "",
                                                category: "saved",
                                                initialIndex: index,
                                              ),
                                            ),
                                          );
                                        },

                                        category: 'saved',
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
  final int initialIndex; // Add this

  const InstagramFeedView({
    super.key,
    required this.posts,
    required this.currentUsername,
    required this.currentAvatar,
    required this.category,
    this.initialIndex = 0, // Default to 0
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

    /// 👉 scroll to clicked post
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 50));

      if (!mounted) return;

      if (_scrollController.hasClients) {
        _scrollController.jumpTo(
          widget.initialIndex * MediaQuery.of(context).size.width,
        );
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
      case 'tagged':
        return 'Tagged Photos';
      default:
        return 'Saved Posts';
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
          return InstagramPost(
            post: widget.posts[index],
            currentAvatar: widget.currentAvatar,
            currentUsername: widget.currentUsername,
            category: widget.category,
          );
        },
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
          views: post["views"] ?? post["watchCount"] ?? 0,
          onTap: () => onImageTap(index),
          // Pass the index
          isVideo: post['isVideo'] == true,
          category: category,
        );
      },
    );
  }
}

// Post Tile with different indicators
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

    final isFile = imageUrl.startsWith('/');

    // final imageWidget = isFile
    //     ? Image.file(File(imageUrl), fit: BoxFit.cover)
    //     : Image.network(
    //         imageUrl,
    //         fit: BoxFit.cover,
    //         errorBuilder: (_, __, ___) =>
    //             const Center(child: Icon(Icons.error, color: Colors.white)),
    //       );

    final imageWidget = isFile
        ? Image.file(
      File(imageUrl),
      fit: BoxFit.cover,
    )
        : CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(
        color: Colors.black12,
      ),
      errorWidget: (_, __, ___) => const Center(
        child: Icon(Icons.error, color: Colors.white),
      ),
    );

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Stack(
          fit: StackFit.expand,
          children: [
            imageWidget,

            // Video indicator
            if (isVideo)
              const Positioned(
                top: 4,
                right: 4,
                child: Icon(Icons.play_arrow, color: Colors.white, size: 16),
              ),

            // Views count (overlay dark stays white for readability)
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
                      '$views${isVideo ? '' : ' views'}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),

            // Category indicator for saved posts
            if (category == 'saved')
              const Positioned(
                top: 4,
                left: 4,
                child: Icon(Icons.bookmark, color: Colors.white, size: 16),
              ),

            // Tagged indicator
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

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 45,
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
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
                  text,
                  style: const TextStyle(
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
            color: theme.textTheme.bodyMedium?.color,
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

