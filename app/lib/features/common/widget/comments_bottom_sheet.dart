// comments_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:popbom/app/urls.dart';
import 'package:popbom/core/services/network/network_client.dart';

class CommentsBottomSheet extends StatefulWidget {
  final String postId; // ⭐ REQUIRED
  final int commentCount;
  final ValueChanged<int>? onCommentCountChanged;
  final Future<void> Function(String text)? onSendComment;

  const CommentsBottomSheet({
    Key? key,
    required this.postId,
    required this.commentCount,
    this.onCommentCountChanged,
    this.onSendComment,
  }) : super(key: key);

  @override
  State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _replyController = TextEditingController();

  String? _replyingToUsername;
  Map<String, dynamic>? _replyingToComment;

  // comments: each item is a map representing a parent comment with 'replies' list
  final List<Map<String, dynamic>> _comments = [];

  // cache for user info to avoid repeated API calls: { userId: { 'username':..., 'profile':... } }
  final Map<String, Map<String, dynamic>> _userCache = {};

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  // Helper: fetch user info (username + profilePhoto) from API and cache it
  Future<Map<String, dynamic>> _fetchUserInfo(String userId) async {
    if (userId.isEmpty) return {'username': 'user', 'profile': null};

    if (_userCache.containsKey(userId)) {
      return _userCache[userId]!;
    }

    try {
      final res =
      await Get.find<NetworkClient>().getRequest(Urls.getUserProfileById(userId));
      if (!res.isSuccess) {
        _userCache[userId] = {'username': 'user', 'profile': null};
        return _userCache[userId]!;
      }

      final data = res.responseData?['data'] ?? res.responseData;
      // try common fields
      final username = data?['username'] ??
          data?['name'] ??
          data?['id'] ??
          userId;
      final profile = data?['profilePhoto'] ??
          data?['avatar'] ??
          data?['photoUrl'] ??
          null;

      _userCache[userId] = {'username': username, 'profile': profile};
      return _userCache[userId]!;
    } catch (_) {
      _userCache[userId] = {'username': 'user', 'profile': null};
      return _userCache[userId]!;
    }
  }

  Future<void> _loadComments() async {
    final res = await Get.find<NetworkClient>()
        .getRequest(Urls.getCommentsByPostId(widget.postId));

    if (!res.isSuccess) return;

    final List list = res.responseData?['data'] ?? [];

    // separate parents and replies, then attach replies to parents
    Map<String, Map<String, dynamic>> parents = {};
    List<Map<String, dynamic>> replies = [];

    // First pass: create maps (but fetch user info lazily / concurrently)
    // We'll collect futures for fetching user info for performance
    List<Future> fetchFutures = [];

    for (var c in list) {
      // parentCommentId can be object or id string
      final parentId = c['parentCommentId'] is Map
          ? c['parentCommentId']['_id']
          : c['parentCommentId'];

      // userId can be object or string
      String userIdString = '';
      if (c['userId'] is Map) {
        // sometimes backend returns { _id: "...", id: "..." }
        userIdString = (c['userId']['_id'] ?? c['userId']['id'] ?? '').toString();
      } else if (c['userId'] is String) {
        userIdString = c['userId'] as String;
      } else {
        userIdString = '';
      }

      // placeholder map; we'll fill username/profile after fetch
      final map = {
        'id': c['_id'],
        'userId': userIdString,
        'username': 'user', // fallback until fetched
        'profile': null,
        'text': c['comment'],
        'time': c['createdAt'],
        'parentId': parentId,
        'replies': <Map<String, dynamic>>[],
        'showReplies': false,
      };

      // schedule user fetch if needed
      if (userIdString.isNotEmpty && !_userCache.containsKey(userIdString)) {
        fetchFutures.add(_fetchUserInfo(userIdString));
      }

      if (parentId == null) {
        parents[c['_id']] = map;
      } else {
        replies.add(map);
      }
    }

    // Wait for all user fetches to finish (if any)
    if (fetchFutures.isNotEmpty) {
      try {
        await Future.wait(fetchFutures);
      } catch (_) {
        // ignore errors; cache will have fallbacks
      }
    }

    // Now assign username/profile values from cache
    for (var p in parents.values) {
      final uid = p['userId'] as String? ?? '';
      if (uid.isNotEmpty && _userCache.containsKey(uid)) {
        p['username'] = _userCache[uid]?['username'] ?? p['username'];
        p['profile'] = _userCache[uid]?['profile'];
      }
    }

    for (var r in replies) {
      final uid = r['userId'] as String? ?? '';
      if (uid.isNotEmpty && _userCache.containsKey(uid)) {
        r['username'] = _userCache[uid]?['username'] ?? r['username'];
        r['profile'] = _userCache[uid]?['profile'];
      }
    }

    // attach replies to parents (by parentId)
    for (var r in replies) {
      final pid = r['parentId'];
      if (pid != null && parents.containsKey(pid)) {
        parents[pid]!['replies'].add(r);
      } else {
        // If parent is missing (edge-case), treat as root
        parents[r['id']] = r;
      }
    }

    if (!mounted) return;
    setState(() {
      _comments.clear();
      // convert to list preserving no specific order; you can sort by time if needed
      _comments.addAll(parents.values);
    });

    widget.onCommentCountChanged?.call(_comments.length);
  }

  // SEND NEW COMMENT (root comment)
  Future<void> _sendMainComment() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final res = await Get.find<NetworkClient>().postRequest(
      Urls.createCommentOnPost,
      body: {"postId": widget.postId, "comment": text},
    );

    if (!res.isSuccess) {
      // optionally show snack
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to send comment")),
        );
      }
      return;
    }

    final d = res.responseData?['data'];
    if (d == null) return;

    // extract userId (could be string or object)
    String userIdString = '';
    if (d['userId'] is Map) {
      userIdString = (d['userId']['_id'] ?? d['userId']['id'] ?? '').toString();
    } else if (d['userId'] is String) {
      userIdString = d['userId'] as String;
    }

    // fetch user info (or get from cache)
    Map<String, dynamic> userInfo = {'username': 'you', 'profile': null};
    if (userIdString.isNotEmpty) {
      userInfo = await _fetchUserInfo(userIdString);
    }

    final newComment = {
      'id': d['_id'],
      'userId': userIdString,
      'username': userInfo['username'] ?? 'you',
      'profile': userInfo['profile'],
      'text': d['comment'] ?? text,
      'time': d['createdAt'] ?? DateTime.now().toIso8601String(),
      'parentId': null,
      'replies': <Map<String, dynamic>>[],
      'showReplies': false,
    };

    if (!mounted) return;
    setState(() {
      _comments.insert(0, newComment);
    });

    widget.onCommentCountChanged?.call(_comments.length);
    _controller.clear();
  }

  // SEND REPLY TO A PARENT COMMENT
  Future<void> _submitReply(String replyText, Map<String, dynamic> parent) async {
    if (replyText.trim().isEmpty) return;

    final res = await Get.find<NetworkClient>().postRequest(
      Urls.createCommentOnPost,
      body: {
        "postId": widget.postId,
        "parentCommentId": parent['id'],
        "comment": replyText
      },
    );

    if (!res.isSuccess) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to send reply")),
        );
      }
      return;
    }

    final d = res.responseData?['data'];
    if (d == null) return;

    // extract userId
    String userIdString = '';
    if (d['userId'] is Map) {
      userIdString = (d['userId']['_id'] ?? d['userId']['id'] ?? '').toString();
    } else if (d['userId'] is String) {
      userIdString = d['userId'] as String;
    }

    Map<String, dynamic> userInfo = {'username': 'you', 'profile': null};
    if (userIdString.isNotEmpty) {
      userInfo = await _fetchUserInfo(userIdString);
    }

    final reply = {
      'id': d['_id'],
      'userId': userIdString,
      'username': userInfo['username'] ?? 'you',
      'profile': userInfo['profile'],
      'text': d['comment'] ?? replyText,
      'time': d['createdAt'] ?? DateTime.now().toIso8601String(),
      'parentId': parent['id'],
      'replies': <Map<String, dynamic>>[],
      'showReplies': false,
    };

    if (!mounted) return;
    setState(() {
      // attach to parent replies
      parent['replies'].insert(0, reply);
      parent['showReplies'] = true;
      _replyingToUsername = null;
      _replyingToComment = null;
    });

    _replyController.clear();
    widget.onCommentCountChanged?.call(_comments.length);
  }

  void _startReply(Map<String, dynamic> comment) {
    setState(() {
      _replyingToUsername = comment['username'];
      _replyingToComment = comment;
    });
  }

  Future<void> _deleteComment(String commentId) async {
    final res = await Get.find<NetworkClient>()
        .deleteRequest("${Urls.baseUrl}/api/comments/$commentId");

    if (!res.isSuccess) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to delete comment")),
        );
      }
      return;
    }

    if (!mounted) return;
    setState(() {
      _comments.removeWhere((c) => c['id'] == commentId);

      // also remove from any parent's replies
      for (var p in _comments) {
        p['replies'].removeWhere((r) => r['id'] == commentId);
      }
    });

    widget.onCommentCountChanged?.call(_comments.length);
  }

  void _toggleReplies(Map<String, dynamic> comment) {
    setState(() {
      comment['showReplies'] = !(comment['showReplies'] ?? false);
    });
  }

  // DELETE CONFIRMATION DIALOG
  void _showDeleteDialog(String commentId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Comment?"),
        content: const Text("Are you sure you want to delete this comment?"),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(ctx),
          ),
          TextButton(
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.pop(ctx);
              _deleteComment(commentId);
            },
          ),
        ],
      ),
    );
  }

  /// UI BELOW — unchanged layout but uses profile & username from API
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * .8,
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              Text('Comments',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  )),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _comments.length,
                  itemBuilder: (context, index) {
                    final c = _comments[index];
                    return _buildCommentWithReplies(
                      c,
                      theme,
                      cs,
                      _startReply,
                      _toggleReplies,
                      depth: 0,
                    );
                  },
                ),
              ),
              if (_replyingToUsername != null)
                _buildReplyField(cs, theme),
              if (_replyingToUsername == null) _buildMainCommentField(cs, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainCommentField(ColorScheme cs, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Add a comment...',
                filled: true,
                fillColor: cs.surfaceVariant.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: theme.dividerColor),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.send, color: cs.primary),
            onPressed: _sendMainComment,
          ),
        ],
      ),
    );
  }

  Widget _buildReplyField(ColorScheme cs, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surfaceVariant.withOpacity(0.3),
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text('Replying to $_replyingToUsername',
                  style: theme.textTheme.bodySmall?.copyWith(color: cs.primary)),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _replyingToUsername = null;
                    _replyingToComment = null;
                  });
                },
                child: Icon(Icons.close, size: 18, color: cs.primary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _replyController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Write your reply...',
                    filled: true,
                    fillColor: cs.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.send, color: cs.primary),
                onPressed: () =>
                    _submitReply(_replyController.text, _replyingToComment!),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommentWithReplies(
      Map<String, dynamic> comment,
      ThemeData theme,
      ColorScheme cs,
      Function(Map<String, dynamic>) onReplyPressed,
      Function(Map<String, dynamic>) onToggleReplies, {
        int depth = 0,
      }) {
    final replies = comment['replies'] as List<dynamic>;
    final showReplies = comment['showReplies'] ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCommentItem(
          comment,
          theme,
          cs,
              () => onReplyPressed(comment),
          isReply: depth > 0,
        ),
        if (replies.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(left: depth == 0 ? 16 : 48),
            child: GestureDetector(
              onTap: () => onToggleReplies(comment),
              child: Text(
                showReplies ? "Hide replies" : "See ${replies.length} replies",
                style: TextStyle(color: cs.primary),
              ),
            ),
          ),
        if (showReplies)
          Padding(
            padding: EdgeInsets.only(left: depth == 0 ? 48 : 16),
            child: Column(
              children: replies.map((reply) {
                return _buildCommentWithReplies(
                  reply,
                  theme,
                  cs,
                  onReplyPressed,
                  onToggleReplies,
                  depth: depth + 1,
                );
              }).toList(),
            ),
          ),
        if (depth == 0) Divider(color: theme.dividerColor.withOpacity(0.2)),
      ],
    );
  }

  /// LONG PRESS -> DELETE (UI same)
  Widget _buildCommentItem(
      Map<String, dynamic> c,
      ThemeData theme,
      ColorScheme cs,
      VoidCallback onReplyPressed, {
        bool isReply = false,
      }) {
    return GestureDetector(
      onLongPress: () => _showDeleteDialog(c['id']),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: isReply ? 0 : 16, vertical: 8),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: (c['profile'] != null && c['profile'].toString().isNotEmpty)
                  ? NetworkImage(c['profile'])
                  : null,
              backgroundColor: cs.primary.withOpacity(.1),
              child: (c['profile'] == null || c['profile'].toString().isEmpty)
                  ? Icon(Icons.person, color: cs.primary, size: 18)
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        c['username'] ?? 'user',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatTime(c['time']),
                        style: TextStyle(
                          color: cs.onSurface.withOpacity(.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(c['text'] ?? '', style: TextStyle(color: cs.onSurface)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: onReplyPressed,
                    child: Text("Reply", style: TextStyle(color: cs.primary)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // small helper to display readable time (keeps original if unknown)
  String _formatTime(dynamic t) {
    try {
      if (t == null) return '';
      final s = t.toString();
      // If it's already an ISO date, show a short version (you can improve formatting)
      if (s.contains('T')) {
        final dt = DateTime.parse(s).toLocal();
        final now = DateTime.now();
        final diff = now.difference(dt);
        if (diff.inMinutes < 1) return 'Just now';
        if (diff.inHours < 1) return '${diff.inMinutes}m';
        if (diff.inDays < 1) return '${diff.inHours}h';
        if (diff.inDays < 7) return '${diff.inDays}d';
        return '${dt.day}/${dt.month}/${dt.year}';
      }
      return s;
    } catch (_) {
      return t.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _replyController.dispose();
    super.dispose();
  }
}
