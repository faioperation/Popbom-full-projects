import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:popbom/features/common/ui/widgets/centered_circular_progress_indicator.dart';
import 'package:popbom/features/home/controller/story_reaction_and_comment_controller.dart';
import 'package:popbom/features/home/widgets/story_media_view.dart';

class Story {
  const Story({
    required this.id,
    required this.name,
    required this.avatar,
    required this.media,
    this.isLive = false,
    this.seen = false,
    required this.userId,
    this.storyIds = const [],
  });

  final String id;
  final String name;
  final String avatar;
  final List<String> media;
  final bool isLive;
  final bool seen;
  final String userId;
  final List<String> storyIds;

  Story copyWith({bool? seen, List<String>? storyIds}) => Story(
    id: id,
    name: name,
    avatar: avatar,
    media: media,
    isLive: isLive,
    seen: seen ?? this.seen,
    userId: userId,
    storyIds: storyIds ?? this.storyIds,
  );
}

class StoryItem extends StatefulWidget {
  const StoryItem({required this.story, required this.onTap});

  final Story story;
  final VoidCallback onTap;

  @override
  State<StoryItem> createState() => _StoryItemState();
}

class _StoryItemState extends State<StoryItem> {
  @override
  Widget build(BuildContext context) {
    final bool isSeen = widget.story.seen;
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        GestureDetector(
          onTap: widget.onTap,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              if (widget.story.id == 'create')
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF21E9A3), Color(0xFF6DF844)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.black45,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, color: Colors.black, size: 28),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    gradient: !isSeen
                        ? const LinearGradient(
                      colors: [Color(0xff21E6A0), Color(0xFF6DF844)],
                    )
                        : null,
                    color: isSeen
                        ? Theme.of(context).dividerColor.withOpacity(0.5)
                        : null,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: cs.surface,
                    backgroundImage: CachedNetworkImageProvider(
                      widget.story.avatar,
                      maxHeight: 150,
                      maxWidth: 150,
                    ),
                  ),
                ),

              if (widget.story.isLive && widget.story.id != 'create')
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      "LIVE",
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 66,
          child: Text(
            widget.story.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 12,
              color: cs.onBackground,
            ),
          ),
        ),
      ],
    );
  }
}

class StoryViewer extends StatefulWidget {
  const StoryViewer({
    required this.story,
    required this.onCompleted,
    required this.nextProvider,
    required this.prevProvider,
    required this.onStorySeen,
    required this.currentUserId,
    required this.isMyStory,
  });

  final Story story;
  final VoidCallback onCompleted;
  final Story? Function(String currentId) nextProvider;
  final Story? Function(String currentId) prevProvider;
  final void Function(String storyId, String viewerId) onStorySeen;
  final String currentUserId;
  final bool isMyStory;

  @override
  State<StoryViewer> createState() => _StoryViewerState();
}

class _StoryViewerState extends State<StoryViewer>
    with SingleTickerProviderStateMixin {
  late final PageController _pc;
  late final AnimationController _progress;
  int _page = 0;
  final Duration _perSlide = const Duration(seconds: 6);
  bool _paused = false;
  double _totalDragDy = 0;

  final List<String> _viewers = [];
  final DateTime _storyCreatedAt = DateTime.now();

  final TextEditingController _replyCtrl = TextEditingController();
  final FocusNode _replyFocus = FocusNode();

  final StoryReactionController reactionController = Get.find<StoryReactionController>();

  String get _currentStoryId {
    if (_page >= 0 && _page < widget.story.storyIds.length) {
      return widget.story.storyIds[_page];
    }
    return "";
  }


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.isMyStory && widget.story.storyIds.isNotEmpty) {
        reactionController.loadStory(
          widget.story.storyIds.first,
          widget.currentUserId,
        );
      }
    });


    _pc = PageController();
    _progress = AnimationController(vsync: this, duration: _perSlide)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted && !_paused) {
          _goNextMediaOrNextStory();
        }
      });

    _replyFocus.addListener(() {
      if (_replyFocus.hasFocus) {
        _pause();
      } else {
        _resume();
      }
    });

    if (!widget.isMyStory && _currentStoryId.isNotEmpty) {
      _trackViewer(widget.currentUserId);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _progress.forward(from: 0);
    });
  }

  void _trackViewer(String userId) {
    if (!_viewers.contains(userId) && _currentStoryId.isNotEmpty) {
      _viewers.add(userId);
      widget.onStorySeen(_currentStoryId, userId);
    }
  }

  bool get _isStoryExpired {
    final now = DateTime.now();
    return now.difference(_storyCreatedAt).inHours >= 24;
  }

  void _pause() {
    if (_paused) return;
    _paused = true;
    _progress.stop();
  }

  void _resume() {
    if (!_paused) return;
    _paused = false;
    _progress.forward();
  }

  void _goNextMediaOrNextStory() {
    if (_page + 1 < widget.story.media.length) {
      _page += 1;
      _pc.animateToPage(
        _page,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeInOut,
      );
      if (!widget.isMyStory && _currentStoryId.isNotEmpty) {
        reactionController.loadStory(
          _currentStoryId,
          widget.currentUserId,
        );
      }
      _progress.forward(from: 0);
    } else {
      final next = widget.nextProvider(widget.story.id);
      widget.onCompleted();

      if (next != null) {
        if (next.storyIds.isNotEmpty) {
          reactionController.loadStory(
            next.storyIds.first,
            widget.currentUserId,
          );
        }

        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => StoryViewer(
              story: next,
              onCompleted: widget.onCompleted,
              nextProvider: widget.nextProvider,
              prevProvider: widget.prevProvider,
              onStorySeen: widget.onStorySeen,
              currentUserId: widget.currentUserId,
              isMyStory: next.userId == widget.currentUserId,
            ),
            transitionsBuilder: (_, anim, __, child) {
              final tween = Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeOutQuart));
              return SlideTransition(position: anim.drive(tween), child: child);
            },
          ),
        );
      } else {
        Navigator.of(context).pop(true);
      }
    }
  }

  void _goPrevStory() {
    final prev = widget.prevProvider(widget.story.id);

    if (prev != null) {
      if (prev.storyIds.isNotEmpty) {
        reactionController.loadStory(
          prev.storyIds.first,
          widget.currentUserId,
        );
      }

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => StoryViewer(
            story: prev,
            onCompleted: widget.onCompleted,
            nextProvider: widget.nextProvider,
            prevProvider: widget.prevProvider,
            onStorySeen: widget.onStorySeen,
            currentUserId: widget.currentUserId,
            isMyStory: prev.userId == widget.currentUserId,
          ),
          transitionsBuilder: (_, anim, __, child) {
            final tween = Tween<Offset>(
              begin: const Offset(-1, 0),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeOutQuart));
            return SlideTransition(position: anim.drive(tween), child: child);
          },
        ),
      );
    } else {
      Navigator.of(context).pop(false);
    }
  }

  void _toggleLike() {
    if (_currentStoryId.isEmpty) return;

    reactionController.toggleLike(
      storyId: _currentStoryId,
      myUserId: widget.currentUserId,
    );
  }

  void _showViewersAndLikers() {
    if (!widget.isMyStory) return;

    final storyId = _currentStoryId;
    if (storyId.isEmpty) return;

    reactionController.loadStory(
      _currentStoryId,
      widget.currentUserId,
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black.withOpacity(0.9),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Story Insights',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                height: 320,
                child: Obx(() {
                  if (reactionController.loading.value) {
                    return const Center(
                      child: CenteredCircularProgressIndicator(),
                    );
                  }

                  if (reactionController.reactions.isEmpty) {
                    return const Center(
                      child: Text(
                        "No reactions yet",
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: reactionController.reactions.length,
                    itemBuilder: (context, index) {
                      final r = reactionController.reactions[index];
                      final user = r['userId'];

                      return ListTile(
                        leading: const CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.grey,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text(
                          user?['username'] ?? 'Unknown',
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          r['reaction'] ?? '',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _pc.dispose();
    _progress.dispose();
    _replyCtrl.dispose();
    _replyFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = widget.story.media;

    if (_isStoryExpired) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('This story has expired'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      });
      return Scaffold(backgroundColor: Colors.black);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GestureDetector(
          onPanDown: (_) => _pause(),
          onPanEnd: (_) => _resume(),
          onVerticalDragStart: (_) => _totalDragDy = 0,
          onVerticalDragUpdate: (d) {
            _totalDragDy += d.delta.dy;
            if (_totalDragDy > 80) {
              widget.onCompleted();
              Navigator.of(context).pop(false);
            }
          },
          child: Stack(
            children: [
              PageView.builder(
                controller: _pc,
                physics: const PageScrollPhysics(),
                onPageChanged: (i) {
                  _page = i;
                  _progress.forward(from: 0);

                  if (!widget.isMyStory && _currentStoryId.isNotEmpty) {
                    reactionController.loadStory(
                      _currentStoryId,
                      widget.currentUserId,
                    );
                  }
                },
                itemCount: media.length,
                itemBuilder: (_, i) => StoryMediaView(
                  url: media[i],
                  onMediaReady: (){
                    _progress.forward(from: 0);
                  },
                ),

              ),

              Positioned(
                top: 10,
                left: 8,
                right: 8,
                child: Column(
                  children: [
                    Row(
                      children: List.generate(media.length, (i) {
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: i == media.length - 1 ? 0 : 4,
                            ),
                            child: AnimatedBuilder(
                              animation: _progress,
                              builder: (_, __) => LinearProgressIndicator(
                                minHeight: 2.6,
                                backgroundColor: Colors.white24,
                                valueColor: const AlwaysStoppedAnimation(
                                  Colors.white,
                                ),
                                value: i < _page
                                    ? 1
                                    : i == _page
                                    ? _progress.value
                                    : 0,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: CachedNetworkImageProvider(
                            widget.story.avatar,
                            maxHeight: 100,
                            maxWidth: 100,
                          ),
                          radius: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.story.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        // ❌ Eye icon remove করা হয়েছে (এখন bottom-এ আছে)
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              widget.onCompleted();
                              Navigator.of(context).pop(false);
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(12),
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Positioned(
                left: 0,
                right: 0,
                top: 56,
                bottom: 120,
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTapUp: (_) {
                          _pause();
                          _goPrevStory();
                          _resume();
                        },
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTapUp: (_) {
                          _pause();
                          _goNextMediaOrNextStory();
                          _resume();
                        },
                      ),
                    ),
                  ],
                ),
              ),


              if (widget.isMyStory)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 80,
                  child: Center(
                    child: GestureDetector(
                      onTap: _showViewersAndLikers,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.insights, color: Colors.white, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'Story Insights',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // ✅ Modified: আপনার নিজের story তে reaction/comment দেখাবে না
              if (!widget.isMyStory)
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
                          onPressed: _toggleLike,
                          icon: Obx(() {
                            return Icon(
                              reactionController.likedByMe.value
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: reactionController.likedByMe.value
                                  ? Colors.red
                                  : Colors.white,
                              size: 28,
                            );
                          }),
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
                                  focusNode: _replyFocus,
                                  controller: _replyCtrl,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(
                                    hintText: 'Send a quick reply…',
                                    hintStyle: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.send, color: Colors.white),
                                  onPressed: () async {
                                    final text = _replyCtrl.text.trim();
                                    if (text.isEmpty) return;

                                    final ok = await reactionController.sendReply(
                                      storyId: _currentStoryId,
                                      message: text,
                                      myUserId: widget.currentUserId,
                                    );

                                    if (!mounted) return;

                                    if (ok) {
                                      _replyCtrl.clear();          // ✅ clear text
                                      _replyFocus.unfocus();       // ✅ keyboard hide
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Failed to send reply'),
                                        ),
                                      );
                                    }
                                  }
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
      ),
    );
  }
}
