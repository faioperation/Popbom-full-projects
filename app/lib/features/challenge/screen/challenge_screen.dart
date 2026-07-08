import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:popbom/features/challenge/controller/challenge_details_controller.dart';
import 'package:popbom/features/common/ui/screen/camera_record_screen.dart';
import 'package:popbom/features/common/ui/screen/post_screen.dart';

class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({super.key, required this.challengeId});

  final String challengeId;

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  bool following = false;
  bool liked = false;
  int likes = 0;
  int comments = 3;
  bool saved = false;
  int saves = 0;
  bool showTranslation = false;
  bool accepted = false;

  // Use Get.put so controller is available and persisted while screen alive
  final ChallengeDetailsController c = Get.put(ChallengeDetailsController());

  @override
  void initState() {
    super.initState();
    // fetch the challenge by id
    c.fetchChallenge(widget.challengeId);
  }

  static const green1 = Color(0xff21E6A0);
  static const green2 = Color(0xFF6DF844);

  String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }

  void _toggleLike() => setState(() {
    liked = !liked;
    likes += liked ? 1 : -1;
  });

  void _toggleSave() => setState(() {
    saved = !saved;
    saves += saved ? 1 : -1;
  });

  // COMMENTS — unchanged
  void _openComments() {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final TextEditingController _controller = TextEditingController();
    String? _replyingToUsername;
    String? _replyingToCommentId;

    final List<Map<String, dynamic>> _comments = [
      {
        'id': '1',
        'username': 'the_leave_click',
        'text': 'Awesome video! Loved the idea 🔥',
        'replies': [
          {
            'id': '1-1',
            'username': 'mike23',
            'text': 'Same here!',
            'replies': [],
          },
        ],
      },
      {
        'id': '2',
        'username': 'lucy_arts',
        'text': 'This challenge looks fun 😍',
        'replies': [],
      },
    ];

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return FractionallySizedBox(
          heightFactor: 0.5, // 50% height
          child: StatefulBuilder(
            builder: (ctx, setLocal) {
              void _addComment(String text) {
                setState(() {
                  _comments.add({
                    'id': DateTime.now().millisecondsSinceEpoch.toString(),
                    'username': 'you',
                    'text': text,
                    'replies': [],
                  });
                  comments++;
                });
              }

              void _addReply(
                String parentId,
                String text,
                List<Map<String, dynamic>> list,
              ) {
                for (final c in list) {
                  if (c['id'] == parentId) {
                    c['replies'].add({
                      'id': DateTime.now().millisecondsSinceEpoch.toString(),
                      'username': 'you',
                      'text': text,
                      'replies': [],
                    });
                    return;
                  }
                  _addReply(
                    parentId,
                    text,
                    List<Map<String, dynamic>>.from(c['replies']),
                  );
                }
              }

              void _toggleReplies(Map<String, dynamic> comment) {
                setLocal(() {
                  comment['showReplies'] = !(comment['showReplies'] ?? false);
                });
              }

              void _startReply(String username, String commentId) {
                setLocal(() {
                  _replyingToUsername = username;
                  _replyingToCommentId = commentId;
                  _controller.text = '@$username ';
                  _controller.selection = TextSelection.fromPosition(
                    TextPosition(offset: _controller.text.length),
                  );
                });
              }

              void _submit() {
                final text = _controller.text.trim();
                if (text.isEmpty) return;

                if (_replyingToCommentId != null) {
                  _addReply(_replyingToCommentId!, text, _comments);
                } else {
                  _addComment(text);
                }

                setLocal(() {
                  _controller.clear();
                  _replyingToUsername = null;
                  _replyingToCommentId = null;
                });
              }

              Widget _buildComment(Map<String, dynamic> c, {int depth = 0}) {
                final replies = List<Map<String, dynamic>>.from(c['replies']);
                return Padding(
                  padding: EdgeInsets.only(left: depth * 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          radius: 16,
                          backgroundColor: cs.primary.withOpacity(0.1),
                          child: Icon(
                            Icons.person,
                            color: cs.primary,
                            size: 16,
                          ),
                        ),
                        title: Text(
                          c['username'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: cs.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          c['text'],
                          style: TextStyle(color: cs.onSurface),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 56),
                        child: Row(
                          children: [
                            TextButton(
                              onPressed: () =>
                                  _startReply(c['username'], c['id']),
                              child: const Text(
                                'Reply',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            if (replies.isNotEmpty)
                              TextButton(
                                onPressed: () => _toggleReplies(c),
                                child: Text(
                                  (c['showReplies'] ?? false)
                                      ? 'Hide replies'
                                      : 'See replies (${replies.length})',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (c['showReplies'] ?? false)
                        ...replies
                            .map((r) => _buildComment(r, depth: depth + 1))
                            .toList(),
                    ],
                  ),
                );
              }

              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Comments',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _comments.length,
                          itemBuilder: (ctx, i) => _buildComment(_comments[i]),
                        ),
                      ),
                      if (_replyingToUsername != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          margin: const EdgeInsets.only(bottom: 4),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHighest.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Replying to @$_replyingToUsername',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: cs.onSurface.withOpacity(0.7),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.close,
                                  size: 16,
                                  color: cs.onSurface.withOpacity(0.6),
                                ),
                                onPressed: () => setLocal(() {
                                  _replyingToUsername = null;
                                  _replyingToCommentId = null;
                                }),
                              ),
                            ],
                          ),
                        ),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              decoration: InputDecoration(
                                hintText: _replyingToUsername != null
                                    ? 'Reply to @$_replyingToUsername...'
                                    : 'Write a comment...',
                                filled: true,
                                fillColor: cs.surfaceContainer,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                              style: TextStyle(color: cs.onSurface),
                              onSubmitted: (_) => _submit(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [green1, green2],
                              ),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: IconButton(
                              onPressed: _submit,
                              icon: const Icon(
                                Icons.send,
                                color: Colors.black,
                                size: 20,
                              ),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // GIFTS — unchanged
  void _openGift() {
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

    showModalBottomSheet(
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
                  color: on
                      ? cs.primary.withOpacity(0.08)
                      : cs.surface.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: on
                        ? cs.primary
                        : theme.dividerColor.withOpacity(0.6),
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
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
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
                          colors: [green1, green2],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: selected.isEmpty
                            ? theme.disabledColor.withOpacity(0.2)
                            : null,
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: theme.colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        onPressed: selected.isEmpty
                            ? null
                            : () {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Sent ${selected.length} gift(s)',
                                    ),
                                  ),
                                );
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

  void _onAccept() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CameraRecordScreen(
          challengeId: widget.challengeId,
        ),
      ),
    );
  }


  String _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return "N/A";
    try {
      final d = DateTime.parse(iso);
      return "${d.day}/${d.month}/${d.year}";
    } catch (_) {
      return "N/A";
    }
  }

  List<String> _parseRules(dynamic rulesField) {
    if (rulesField == null) return [];
    if (rulesField is List) return rulesField.map((e) => e.toString()).toList();
    if (rulesField is String) {
      if (rulesField.contains('|'))
        return rulesField
            .split('|')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
      if (rulesField.contains('\n'))
        return rulesField
            .split('\n')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
      return [rulesField];
    }
    return [rulesField.toString()];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // media background gradient
    final mediaBgGradient = LinearGradient(
      colors: [
        cs.background,
        cs.surface.withOpacity(
          theme.brightness == Brightness.dark ? 0.25 : 0.15,
        ),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return GetBuilder<ChallengeDetailsController>(
      builder: (ctrl) {
        // Loading
        if (ctrl.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Error or no data
        if (ctrl.data == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Challenge')),
            body: Center(
              child: Text(ctrl.error ?? "No challenge data available"),
            ),
          );
        }

        // Data exists
        final data = ctrl.data!;
        final author = data['author'] ?? {};
        final participants = (data['participants'] ?? []) as List<dynamic>;
        final totalParticipants =
            data['totalParticipants'] ?? participants.length;

        // Use parsed rules if present
        final rulesFromServer = _parseRules(data['rules'] ?? []);

        return Scaffold(
          backgroundColor: cs.background,
          appBar: AppBar(
            title: Text(
              'Challenge',
              style:
                  theme.appBarTheme.titleTextStyle ??
                  theme.textTheme.titleLarge?.copyWith(
                    color: theme.appBarTheme.foregroundColor ?? cs.onBackground,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
            ),
            backgroundColor: theme.appBarTheme.backgroundColor ?? cs.background,
            elevation: theme.appBarTheme.elevation ?? 0,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: theme.appBarTheme.foregroundColor ?? cs.onBackground,
                size: 18,
              ),
              onPressed: () => Navigator.maybePop(context),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            children: [
              // MAIN MEDIA block
              Container(
                decoration: BoxDecoration(
                  gradient: mediaBgGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    // Right-side actions
                    // Positioned(
                    //   right: 8,
                    //   top: 8,
                    //   bottom: 8,
                    //   child: Column(
                    //     mainAxisAlignment: MainAxisAlignment.center,
                    //     children: [
                    //       InkWell(
                    //         onTap: _toggleLike,
                    //         borderRadius: BorderRadius.circular(12),
                    //         child: Column(
                    //           children: [
                    //             Icon(
                    //               liked ? Icons.favorite : Icons.favorite_border,
                    //               color: liked ? Colors.red : cs.onBackground,
                    //             ),
                    //             const SizedBox(height: 4),
                    //             Text(
                    //               _fmt(likes),
                    //               style: TextStyle(color: cs.onBackground, fontSize: 12),
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //       const SizedBox(height: 16),
                    //       InkWell(
                    //         onTap: _openComments,
                    //         borderRadius: BorderRadius.circular(12),
                    //         child: Column(
                    //           children: [
                    //             // if you don't have svg asset at runtime, it won't render but kept same as before
                    //             SvgPicture.asset(
                    //               'assets/icon/comment.svg',
                    //               width: 22,
                    //               height: 22,
                    //               colorFilter: ColorFilter.mode(
                    //                 Theme.of(context).colorScheme.onSurface,
                    //                 BlendMode.srcIn,
                    //               ),
                    //             ),
                    //             const SizedBox(height: 4),
                    //             Text(_fmt(comments), style: TextStyle(color: cs.onBackground, fontSize: 12)),
                    //           ],
                    //         ),
                    //       ),
                    //       const SizedBox(height: 16),
                    //       InkWell(
                    //         onTap: _openGift,
                    //         borderRadius: BorderRadius.circular(12),
                    //         child: Column(
                    //           children: [
                    //             Icon(Icons.card_giftcard_outlined, color: cs.onBackground),
                    //             const SizedBox(height: 4),
                    //             Text('Gift', style: TextStyle(color: cs.onBackground, fontSize: 12)),
                    //           ],
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // header (author avatar + name + follow)
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: cs.surface,
                                backgroundImage: (author['photo'] != null &&
                                        author['photo'].toString().isNotEmpty)
                                    ? CachedNetworkImageProvider(author['photo'],
                                        maxHeight: 120, maxWidth: 120)
                                    : null,
                                child:
                                    (author['photo'] == null ||
                                        author['photo'].toString().isEmpty)
                                    ? Icon(
                                        Icons.person,
                                        color: theme.iconTheme.color,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      author['name'] ??
                                          (author['username'] ?? 'Unknown'),
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: cs.onBackground,
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      author['username'] != null
                                          ? "@${author['username']}"
                                          : "",
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: theme
                                                .textTheme
                                                .bodyMedium
                                                ?.color,
                                            fontSize: 12,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed: () =>
                                    setState(() => following = !following),
                                child: Text(
                                  following ? 'Following' : 'Follow +',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: cs.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // BIG image + OVERLAY
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              children: [
                                AspectRatio(
                                  aspectRatio: 3 / 4,
                                child: (data['challengePoster'] != null &&
                                        data['challengePoster']
                                            .toString()
                                            .isNotEmpty)
                                    ? CachedNetworkImage(
                                        imageUrl: data['challengePoster'],
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        memCacheHeight: 600,
                                      )
                                    : Container(color: cs.surface),
                                ),

                                // Bottom overlay card with texts
                                Positioned(
                                  left: 10,
                                  right: 10,
                                  bottom: 10,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: cs.surface.withOpacity(0.92),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          data['challengeName'] ?? 'Challenge',
                                          style: theme.textTheme.bodyLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                                color: cs.onSurface,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        // description if provided
                                        if ((data['challengeDesc'] ?? '')
                                            .toString()
                                            .isNotEmpty)
                                          Text(
                                            data['challengeDesc'],
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(color: cs.onSurface),
                                          ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.calendar_today,
                                              size: 14,
                                              color: theme
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.color,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              "Starts: ${_formatDate(data['challengeStartDate'])}",
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                    color: theme
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.color,
                                                  ),
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              "Ends: ${_formatDate(data['challengeEndDate'])}",
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                    color: theme
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.color,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // RULES header
              Text(
                'Challenge Rules',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: cs.onBackground,
                ),
              ),
              const SizedBox(height: 8),

              // Rules list (from server if any, otherwise fallback to example)
              ...rulesFromServer.map(
                (r) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("• "),
                      Expanded(
                        child: Text(r, style: const TextStyle(fontSize: 14)),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Participants header + count
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Row(
                  children: [
                    Text(
                      'Participants',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: cs.onBackground,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${totalParticipants ?? participants.length})',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Participants list (show avatars + names)
              SizedBox(
                height: 90,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, i) {
                    final p = participants[i];
                    return Column(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundImage:
                              (p['photo'] != null &&
                                  p['photo'].toString().isNotEmpty)
                              ? CachedNetworkImageProvider(p['photo'],
                                  maxHeight: 120, maxWidth: 120)
                              : null,
                          child:
                              (p['photo'] == null ||
                                  p['photo'].toString().isEmpty)
                              ? Icon(Icons.person, color: cs.onSurface)
                              : null,
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: 80,
                          child: Text(
                            p['name'] ?? p['username'] ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onBackground,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemCount: participants.length,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.background,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              height: 54,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [green1, green2]),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    textStyle: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  onPressed: accepted ? null : _onAccept,
                  child: Text(accepted ? 'Accepted' : 'Accept Challenge'),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
