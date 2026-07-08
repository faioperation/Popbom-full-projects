import 'dart:io';
import 'package:flutter/material.dart';
import 'package:popbom/features/common/ui/screen/post_screen.dart';
import 'package:video_player/video_player.dart';

class VideoPreviewScreen extends StatefulWidget {
  const VideoPreviewScreen({
    super.key,
    required this.filePath,
    this.playbackSpeed = 1.0,
    this.challengeId,
  });

  final String filePath;
  final double playbackSpeed;
  final String? challengeId;

  @override
  State<VideoPreviewScreen> createState() => _VideoPreviewScreenState();
}

class _VideoPreviewScreenState extends State<VideoPreviewScreen> {
  late final VideoPlayerController _controller = VideoPlayerController.file(
    File(widget.filePath),
  );

  bool _ready = false;
  bool _muted = false;
  bool _showCenterPlay = false;

  // 🔥 Fix: Store listener to properly remove it
  late final VoidCallback _listener;

  @override
  void initState() {
    super.initState();
    _listener = () {
      if (!mounted) return;
      setState(() {}); // rebuild to update time/slider
    };
    _init();
  }

  Future<void> _init() async {
    await _controller.initialize();
    await _controller.setLooping(true);
    await _controller.setPlaybackSpeed(widget.playbackSpeed.clamp(0.25, 3.0));
    await _controller.setVolume(1);
    await _controller.play();
    if (mounted) setState(() => _ready = true);

    // keep UI responsive while playing
    _controller.addListener(_listener);
  }

  @override
  void dispose() {
    _controller.removeListener(_listener);
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (!_ready) return;
    if (_controller.value.isPlaying) {
      _controller.pause();
      setState(() => _showCenterPlay = true);
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) setState(() => _showCenterPlay = false);
      });
    } else {
      _controller.play();
      setState(() => _showCenterPlay = false);
    }
  }

  Future<void> _toggleMute() async {
    if (!_ready) return;
    _muted = !_muted;
    await _controller.setVolume(_muted ? 0 : 1);
    setState(() {});
  }

  void _seekToPercent(double v) {
    if (!_ready) return;
    final dur = _controller.value.duration;
    final pos = Duration(milliseconds: (dur.inMilliseconds * v).round());
    _controller.seekTo(pos);
  }

  String _fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  void _snack(String msg) {
    final cs = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: cs.inverseSurface,
        content: Text(msg, style: TextStyle(color: cs.onInverseSurface)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final onBg = cs.onBackground;
    final bg = cs.background;

    final position = _controller.value.position;
    final duration = _controller.value.duration == Duration.zero
        ? const Duration(milliseconds: 1)
        : _controller.value.duration;
    final progress = (position.inMilliseconds / duration.inMilliseconds).clamp(
      0.0,
      1.0,
    );

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        iconTheme: IconThemeData(color: onBg),
        title: Text(
          'Preview',
          style: theme.textTheme.titleMedium?.copyWith(
            color: onBg,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        actions: [
          IconButton(
            tooltip: _muted ? 'Unmute' : 'Mute',
            icon: Icon(
              _muted ? Icons.volume_off : Icons.volume_up,
              color: onBg,
            ),
            onPressed: _toggleMute,
          ),
          IconButton(
            tooltip: 'Save',
            icon: Icon(Icons.check, color: onBg),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InstagramPostExactScreen(
                    videoFilePath: widget.filePath,
                    videoController: _controller,
                    challengeId: widget.challengeId,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: !_ready
          ? Center(child: CircularProgressIndicator(color: onBg))
          : Column(
              children: [
                // Video area
                Expanded(
                  child: GestureDetector(
                    onTap: _togglePlayPause,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // cover-fit for nicer preview
                        FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: _controller.value.size.width,
                            height: _controller.value.size.height,
                            child: VideoPlayer(_controller),
                          ),
                        ),

                        // big play icon when paused (or briefly after pausing)
                        if (_showCenterPlay || !_controller.value.isPlaying)
                          Center(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black26,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(10),
                              child: const Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                                size: 64,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Controls
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            _fmt(position),
                            style: TextStyle(
                              color: onBg.withOpacity(.85),
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 3,
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 8,
                                ),
                              ),
                              child: Slider(
                                value: progress.isNaN ? 0 : progress,
                                onChanged: (v) => _seekToPercent(v),
                              ),
                            ),
                          ),
                          Text(
                            _fmt(duration),
                            style: TextStyle(
                              color: onBg.withOpacity(.85),
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // IconButton(
                          //   tooltip: 'Rewind 10s',
                          //   icon: Icon(Icons.replay_10, color: onBg),
                          //   onPressed: () => _controller.seekTo(
                          //     position - const Duration(seconds: 10),
                          //   ),
                          // ),
                          IconButton(
                            tooltip: _controller.value.isPlaying
                                ? 'Pause'
                                : 'Play',
                            icon: Icon(
                              _controller.value.isPlaying
                                  ? Icons.pause_circle_filled
                                  : Icons.play_circle_fill,
                              color: onBg,
                              size: 34,
                            ),
                            onPressed: _togglePlayPause,
                          ),
                          // IconButton(
                          //   tooltip: 'Forward 10s',
                          //   icon: Icon(Icons.forward_10, color: onBg),
                          //   onPressed: () => _controller.seekTo(
                          //     position + const Duration(seconds: 10),
                          //   ),
                          // ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
