import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/root/parse_route.dart';
import 'package:popbom/features/common/controllers/auth_controller.dart';
import 'package:popbom/features/common/widget/comments_bottom_sheet.dart';
import 'package:popbom/features/common/widget/share_sheet.dart';
import 'package:popbom/features/profile/controller/post_action_controller.dart';
import 'package:popbom/features/profile/controller/profile_controller.dart';
import 'package:popbom/features/profile/widgets/video_player_inLine.dart';

class InstagramPost extends StatefulWidget {
  final Map<String, dynamic> post;
  final String currentAvatar;
  final String currentUsername;
  final String category;

  const InstagramPost({
    required this.post,
    required this.currentAvatar,
    required this.currentUsername,
    required this.category,
  });

  @override
  State<InstagramPost> createState() => _InstagramPostState();
}

class _InstagramPostState extends State<InstagramPost> {
  final PostActionsController actionCtrl = Get.find<PostActionsController>();

  bool _isLiked = false;
  bool _isSaved = false;
  int _likeCount = 0;
  int _commentCount = 0;
  String? _reactionId;
  String? _savedRecordId;

  String get _postId {
    return widget.post['_id']?.toString()
        ?? widget.post['postId']?.toString()
        ?? "";
  }


  @override
  void initState() {
    super.initState();

    final profile = Get.find<ProfileController>();

    final p =
        profile.myPosts.firstWhereOrNull((e) => e.id == _postId) ??
        profile.taggedPosts.firstWhereOrNull((e) => e.id == _postId)??
        profile.savedPosts.firstWhereOrNull((e) => e.id == _postId);

    _isLiked = p?.isLiked ?? false;
    _isSaved = p?.isSaved ?? false;
    _reactionId = p?.reactionId;
    _savedRecordId = p?.savedRecordId;
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

    // return Image.network(
    //   url,
    //   fit: BoxFit.cover,
    //   errorBuilder: (_, __, ___) =>
    //       const Center(child: Icon(Icons.error, color: Colors.white)),
    // );

    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      memCacheHeight: 400, // Optimize grid image memory
      placeholder: (_, __) => Container(
        color: Colors.black12,
        height: double.infinity,
        width: double.infinity,
      ),
      errorWidget: (_, __, ___) =>
          const Center(child: Icon(Icons.error, color: Colors.white)),
    );
  }

  void _toggleLike() async {
    final postId = _postId;
    if (postId.isEmpty) return;

    final newState = !_isLiked;

    setState(() {
      _isLiked = newState;
    });

    final profile = Get.find<ProfileController>();
    final index = profile.myPosts.indexWhere((p) => p.id == postId);

    bool success = false;

    if (newState) {
      // ❤️ LIKE
      final reactionId = await actionCtrl.toggleLike(
        postId: postId,
        isLikedNow: true,
      );

      if (reactionId != null) {
        _reactionId = reactionId;

        profile.syncLike(
          postId: postId,
          isLiked: true,
          delta: 1,
          reactionId: reactionId,
        );

        setState(() {
          _likeCount =
              profile.myPosts
                  .firstWhereOrNull((p) => p.id == postId)
                  ?.likeCount ??
              _likeCount;
        });

        success = true;
      }
    } else {
      // 💔 UNLIKE

      // 🔥 FIX HERE: IF reactionId IS NULL → fetch again
      if (_reactionId == null) {
        print("⚠ reactionId missing, fetching from server...");
        final r = await actionCtrl.getReactionByPostId(postId);
        _reactionId = r?['_id'];
      }

      print("🗑 Trying to remove reaction → $_reactionId");

      if (_reactionId == null) {
        final r = await actionCtrl.getReactionByPostId(postId);
        _reactionId = r?['_id'];
      }

      if (_reactionId != null) {
        success = await actionCtrl.removeReaction(_reactionId!);

        if (success) {
          profile.syncLike(
            postId: postId,
            isLiked: false,
            delta: -1,
            reactionId: null,
          );

          setState(() {
            _likeCount =
                profile.myPosts
                    .firstWhereOrNull((p) => p.id == postId)
                    ?.likeCount ??
                _likeCount;
          });

          _reactionId = null;
        }
      }
    }

    if (!success) {
      setState(() {
        _isLiked = !_isLiked;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to remove reaction")),
      );
    }
    final uid = Get.find<ProfileController>().user?.id;
    if (uid != null) {
      Get.find<ProfileController>().fetchTotalReactions(uid);
    }
  }

  void _toggleSave() async {
    final postId = _postId;
    if (postId.isEmpty) return;

    final profile = Get.find<ProfileController>();

    final result = await actionCtrl.toggleSave(
      postId: postId,
      isCurrentlySaved: _isSaved,
      savedRecordId: _savedRecordId, // 🔥 MUST PASS THIS
    );

    if (result == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to update save")));
      return;
    }

    final bool savedNow = result["isSaved"] == true;
    final String? savedId = result["savedRecordId"];

    // 🔑 SINGLE SOURCE OF TRUTH
    profile.syncSave(postId: postId, isSaved: savedNow, savedRecordId: savedId);

    setState(() {
      _isSaved = savedNow;
      _savedRecordId = savedId;
    });
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

              final profile = Get.find<ProfileController>();
              final i = profile.myPosts.indexWhere((p) => p.id == postId);
              if (i != -1) {
                profile.myPosts[i].commentCount =
                    (profile.myPosts[i].commentCount ?? 0) + 1;
                profile.myPosts.refresh();
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

          // Update the counter if BottomSheet changes count
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

    final String currentUserId =
        Get.find<AuthController>().userModel?.id ?? "";

    final String postOwnerId =
        widget.post['authorId']?['_id']?.toString() ?? "";

    final bool isOwner =
        currentUserId.isNotEmpty &&
            postOwnerId.isNotEmpty &&
            currentUserId == postOwnerId;


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
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey.shade800,
                  backgroundImage: (() {
                    if (widget.category == 'posts') {
                      return widget.currentAvatar.isNotEmpty
                          ? CachedNetworkImageProvider(
                              widget.currentAvatar,
                              maxHeight: 100,
                              maxWidth: 100,
                            )
                          : null;
                    } else {
                      final photo = widget.post['userPhoto'] ?? "";
                      return photo.isNotEmpty
                          ? CachedNetworkImageProvider(
                              photo,
                              maxHeight: 100,
                              maxWidth: 100,
                            )
                          : null;
                    }
                  })(),
                  child: (() {
                    final hasPhoto = widget.category == 'posts'
                        ? widget.currentAvatar.isNotEmpty
                        : (widget.post['userPhoto'] ?? "").isNotEmpty;

                    return hasPhoto
                        ? null
                        : Icon(Icons.person, color: Colors.white, size: 16);
                  })(),
                ),

                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.category == 'posts'
                                ? widget.currentUsername
                                : widget.post['username'] ?? "",
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: cs.onBackground,
                            ),
                          ),
                        ],
                      ),
                      if (widget.category == 'tagged') ...[
                        const SizedBox(height: 2),
                        Text(
                          'Tagged ${widget.post['taggedUsers']?.join(', ') ?? ''}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

               // if (isOwner)
               //  IconButton(
               //    icon: Icon(Icons.more_vert, color: theme.iconTheme.color),
               //    onPressed: () {
               //
               //      final profileCtrl = Get.find<ProfileController>();
               //
               //      showModalBottomSheet(
               //        context: context,
               //        backgroundColor: Theme.of(context).colorScheme.surface,
               //        shape: const RoundedRectangleBorder(
               //          borderRadius: BorderRadius.vertical(
               //            top: Radius.circular(14),
               //          ),
               //        ),
               //        builder: (_) {
               //          return SafeArea(
               //            child: Column(
               //              mainAxisSize: MainAxisSize.min,
               //              children: [
               //                  ListTile(
               //                    leading: const Icon(
               //                      Icons.delete,
               //                      color: Colors.red,
               //                    ),
               //                    title: const Text(
               //                      "Delete Post",
               //                      style: TextStyle(color: Colors.red),
               //                    ),
               //                    onTap: () async {
               //                      Navigator.pop(context);
               //
               //                      final confirm = await showDialog<bool>(
               //                        context: context,
               //                        builder: (_) => AlertDialog(
               //                          title: const Text("Delete Post?"),
               //                          content: const Text(
               //                            "Are you sure you want to delete this post? This action cannot be undone.",
               //                          ),
               //                          actions: [
               //                            TextButton(
               //                              child: const Text("Cancel"),
               //                              onPressed: () =>
               //                                  Navigator.pop(context, false),
               //                            ),
               //                            TextButton(
               //                              child: const Text(
               //                                "Delete",
               //                                style: TextStyle(
               //                                  color: Colors.red,
               //                                ),
               //                              ),
               //                              onPressed: () =>
               //                                  Navigator.pop(context, true),
               //                            ),
               //                          ],
               //                        ),
               //                      );
               //
               //                      if (confirm != true) return;
               //
               //                      if (_postId.isEmpty) {
               //                        ScaffoldMessenger.of(context).showSnackBar(
               //                          const SnackBar(
               //                            content: Text("Invalid post id"),
               //                            backgroundColor: Colors.red,
               //                          ),
               //                        );
               //                        return;
               //                      }
               //
               //                      final success = await profileCtrl
               //                          .deletePost(_postId);
               //
               //                      if (success) {
               //                        ScaffoldMessenger.of(context).showSnackBar(
               //                          const SnackBar(
               //                            content: Text("Post deleted successfully"),
               //                            backgroundColor: Colors.green,
               //                          ),
               //                        );
               //
               //                        // 🔥 IF INSIDE FEED VIEW → GO BACK
               //                        if (Navigator.canPop(context)) {
               //                          Navigator.pop(context);
               //                        }
               //                      }
               //                      else {
               //                        ScaffoldMessenger.of(
               //                          context,
               //                        ).showSnackBar(
               //                          const SnackBar(
               //                            content: Text(
               //                              "Failed to delete post",
               //                            ),
               //                            backgroundColor: Colors.red,
               //                          ),
               //                        );
               //                      }
               //                    },
               //                  ),
               //              ],
               //            ),
               //          );
               //        },
               //      );
               //    },
               //  ),
              ],
            ),
          ),

          // Post Image/Video
          SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.width,
            child: isVideo
                ? VideoPlayerInline(
                    url: widget.post['videoUrl'] ?? "",
                    postId: _postId, // ✅ always correct
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
                    text:
                        '${widget.category == 'posts' ? widget.currentUsername : (widget.post['username'] ?? "")} ',
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
