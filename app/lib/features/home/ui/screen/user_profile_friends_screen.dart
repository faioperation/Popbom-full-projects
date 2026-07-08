import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:popbom/features/common/ui/screen/app_shell.dart';
import 'package:popbom/features/common/ui/screen/user_profile_screen.dart';
import 'package:popbom/features/home/controller/user_profile_friend_controller.dart';
import 'package:popbom/features/chat/ui/screen/chat_screen.dart';

class UserProfileFriendsScreen extends StatefulWidget {
  final String userId;
  final VoidCallback? onBack;

  const UserProfileFriendsScreen({
    super.key,
    required this.userId,
    this.onBack,
  });

  @override
  State<UserProfileFriendsScreen> createState() =>
      _UserProfileFriendsScreenState();
}

class _UserProfileFriendsScreenState extends State<UserProfileFriendsScreen> {
  final UserFollowersController c = Get.put(UserFollowersController());

  @override
  void initState() {
    super.initState();
    c.loadFollowers(widget.userId);
  }

  void _goHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AppShell()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return GetBuilder<UserFollowersController>(
      builder: (ctrl) {
        return WillPopScope(
          onWillPop: () async {
            _goHome(context);
            return false;
          },
          child: Scaffold(
            backgroundColor: cs.background,
            appBar: AppBar(
              backgroundColor: cs.background,
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new,
                    color: cs.onBackground, size: 18),
                onPressed: () {
                  if (widget.onBack != null) {
                    widget.onBack!();
                  } else {
                    _goHome(context);
                  }
                },
              ),
              title: Text(
                'Followers',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: cs.onBackground,
                  fontWeight: FontWeight.w600,
                  fontSize: 16
                ),
              ),
            ),

            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: TextField(
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search',
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurface.withOpacity(0.6),
                      ),
                      prefixIcon: Icon(Icons.search,
                          color: cs.onSurface.withOpacity(0.6)),
                      filled: true,
                      fillColor: cs.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: ctrl.loading
                      ? const Center(child: CircularProgressIndicator())
                      : ctrl.followers.isEmpty
                      ? const Center(child: Text("No followers found"))
                      : ListView.separated(
                    itemCount: ctrl.followers.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: theme.dividerColor.withOpacity(0.1),
                    ),
                    itemBuilder: (_, i) {
                      final item = ctrl.followers[i];
                      final user = item["followingUserId"] ?? {};
                      final detail = user["userDetails"] ?? {};

                      return _FriendItem(
                        name: detail["name"] ?? "Unknown",
                        subtitle: "@${user["username"] ?? ''}",
                        avatarUrl: detail["photo"] ?? "",
                        userId: user["_id"] ?? "",
                      );
                    },
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

class _FriendItem extends StatelessWidget {
  final String name;
  final String subtitle;
  final String avatarUrl;
  final String userId;

  const _FriendItem({
    required this.name,
    required this.subtitle,
    required this.avatarUrl,
    required this.userId,
  });

  void _openProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserProfileScreen(
          userId: userId,
          username: name,
          avatarUrl: avatarUrl,
        ),
      ),
    );
  }

  void _showActions(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: cs.surface,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return FractionallySizedBox(
          heightFactor: 0.40,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),

              _ActionTile(
                label: "Message $name",
                svgPath: 'assets/icon/comment.svg',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ChatScreen(friendName: name, friendImage: avatarUrl, friendId: userId, chatId: '',),
                    ),
                  );
                },
              ),

              // _ActionTile(
              //   label: "Unfollow $name",
              //   svgPath: 'assets/icon/unfollow.svg',
              //   onTap: () async {
              //     final success = await Get.find<UserFollowersController>()
              //         .toggleFollow(userId);
              //
              //     Navigator.pop(context);
              //
              //     ScaffoldMessenger.of(context).showSnackBar(
              //       SnackBar(
              //         content: Text(
              //           success ? "Unfollowed" : "Failed to unfollow",
              //         ),
              //       ),
              //     );
              //   },
              // ),

              // BLOCK OPTION RESTORED 🔥
              _ActionTile(
                label: "Block $name",
                svgPath: 'assets/icon/block.svg',
                onTap: () {},
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListTile(
      leading: CircleAvatar(
        radius: 24,
        backgroundImage:
        avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
        child: avatarUrl.isEmpty
            ? Icon(Icons.person, color: cs.onSurface)
            : null,
      ),
      title: Text(
        name,
        style: textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: cs.onBackground,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: textTheme.bodySmall?.copyWith(
          color: cs.onSurface.withOpacity(0.7),
        ),
      ),
      trailing: IconButton(
        icon: Icon(Icons.more_horiz, color: cs.onSurface),
        onPressed: () => _showActions(context),
      ),
      onTap: () => _openProfile(context),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.label,
    required this.onTap,
    required this.svgPath,
  });

  final String label;
  final String svgPath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      leading: SvgPicture.asset(
        svgPath,
        width: 22,
        height: 22,
        colorFilter: ColorFilter.mode(cs.onSurface, BlendMode.srcIn),
      ),
      title: Text(label, style: TextStyle(color: cs.onSurface)),
      onTap: onTap,
    );
  }
}

