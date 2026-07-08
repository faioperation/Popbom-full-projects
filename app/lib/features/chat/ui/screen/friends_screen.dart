import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:popbom/features/chat/controller/chat_list_controller.dart';
import 'package:popbom/features/chat/ui/screen/chat_screen.dart';
import 'package:popbom/features/common/ui/screen/app_shell.dart';
import 'package:popbom/features/common/ui/widgets/centered_circular_progress_indicator.dart';
import 'package:popbom/features/home/controller/user_profile_friend_controller.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key, this.onBack});
  final VoidCallback? onBack;

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  final ChatListController chatListC = Get.find<ChatListController>();
  final UserFollowersController followC =
  Get.find<UserFollowersController>();

  @override
  void initState() {
    super.initState();
    chatListC.loadChatList();
  }

  void _goHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AppShell()),
          (route) => false,
    );
  }

  /// 🔍 SIMPLE SEARCH FILTER (existing chats only)
  List get filteredChats {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return chatListC.chatList;

    return chatListC.chatList.where((c) {
      return c.friendName.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return WillPopScope(
      onWillPop: () async {
        _goHome(context);
        return false;
      },
      child: GetBuilder<ChatListController>(
        builder: (_) {
          return Scaffold(
            backgroundColor: cs.background,
            appBar: AppBar(
              backgroundColor: cs.background,
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new,
                    color: cs.onBackground, size: 18),
                onPressed: () {
                  widget.onBack != null
                      ? widget.onBack!()
                      : _goHome(context);
                },
              ),
              title: Text(
                'Inbox',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: cs.onBackground,
                  fontWeight: FontWeight.w600,fontSize: 16,
                ),
              ),
            ),
            body: Column(
              children: [
                /// 🔍 SEARCH BAR
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: "Search chats",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: cs.surfaceVariant,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                /// CHAT LIST
                Expanded(
                  child: chatListC.isLoading
                      ? const Center(
                      child:
                      CenteredCircularProgressIndicator())
                      : filteredChats.isEmpty
                      ? const Center(
                      child: Text("No chats found"))
                      : RefreshIndicator(
                    onRefresh: () =>
                        chatListC.loadChatList(),
                    child: ListView.separated(
                      physics:
                      const AlwaysScrollableScrollPhysics(),
                      itemCount: filteredChats.length,
                      separatorBuilder: (_, __) =>
                          Divider(
                            height: 1,
                            color: theme.dividerColor
                                .withOpacity(0.1),
                          ),
                      itemBuilder: (_, i) {
                        final item =
                        filteredChats[i];

                        return _FriendItem(
                          name: item.friendName,
                          subtitle:
                          item.lastMessage,
                          avatarUrl:
                          item.friendImage,
                          friendId:
                          item.friendId,
                          chatId: item.chatId,
                          onUnfollow: () async {
                            final ok =
                            await followC
                                .toggleFollow(
                                item.friendId);
                            if (ok) {
                              chatListC
                                  .loadChatList();
                            }
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// ================= FRIEND ITEM =================

class _FriendItem extends StatelessWidget {
  const _FriendItem({
    required this.name,
    required this.subtitle,
    required this.avatarUrl,
    required this.friendId,
    required this.chatId,
    required this.onUnfollow,
  });

  final String name;
  final String subtitle;
  final String avatarUrl;
  final String friendId;
  final String chatId;
  final VoidCallback onUnfollow;

  void _openChat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          friendName: name,
          friendImage: avatarUrl,
          friendId: friendId,
          chatId: chatId,
        ),
      ),
    );
  }

  void _showActions(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return FractionallySizedBox(
          heightFactor: 0.45,
          child: Column(
            children: [
              const SizedBox(height: 12),
              _ActionTile(
                label: "Message $name",
                svgPath: 'assets/icon/comment.svg',
                onTap: () {
                  Navigator.pop(ctx);
                  _openChat(context);
                },
              ),
              _ActionTile(
                label: "Unfollow $name",
                svgPath: 'assets/icon/unfollow.svg',
                onTap: () {
                  Navigator.pop(ctx);
                  onUnfollow();
                },
              ),
              _ActionTile(
                label: "Block $name",
                svgPath: 'assets/icon/block.svg',
                onTap: () => Navigator.pop(ctx),
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
        backgroundColor: Colors.grey.shade300,
        backgroundImage: avatarUrl.startsWith("http")
            ? CachedNetworkImageProvider(avatarUrl,
                maxHeight: 120, maxWidth: 120)
            : null,
        child: !avatarUrl.startsWith("http")
            ? Text(
          name.isNotEmpty ? name[0].toUpperCase() : "?",
          style: const TextStyle(fontWeight: FontWeight.bold),
        )
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
        subtitle.isEmpty ? "Say Hello 👋" : subtitle,
        style: textTheme.bodySmall?.copyWith(
          color: cs.onSurface.withOpacity(0.7),
        ),
      ),
      trailing: IconButton(
        icon: Icon(Icons.more_horiz, color: cs.onSurface),
        onPressed: () => _showActions(context),
      ),
      onTap: () => _openChat(context),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 20),
      leading: SvgPicture.asset(
        svgPath,
        width: 22,
        height: 22,
        colorFilter:
        ColorFilter.mode(cs.onSurface, BlendMode.srcIn),
      ),
      title:
      Text(label, style: TextStyle(color: cs.onSurface)),
      onTap: onTap,
    );
  }
}
