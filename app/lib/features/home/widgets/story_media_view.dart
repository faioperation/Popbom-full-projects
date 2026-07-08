import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class StoryMediaView extends StatefulWidget {
  final String url;
  final VoidCallback? onMediaReady;

  const StoryMediaView({
    super.key,
    required this.url,
    this.onMediaReady,
  });

  @override
  State<StoryMediaView> createState() => _StoryMediaViewState();
}


class _StoryMediaViewState extends State<StoryMediaView> {
  VideoPlayerController? _videoCtrl;

  bool get _isVideo =>
      widget.url.endsWith('.mp4') || widget.url.contains('/video/');

  @override
  void initState() {
    super.initState();

    if (_isVideo) {
      _videoCtrl = VideoPlayerController.networkUrl(Uri.parse(widget.url))
        ..initialize().then((_) {
          _videoCtrl!
            ..setLooping(false)
            ..play();

          widget.onMediaReady?.call(); // ⭐ IMPORTANT
          if (mounted) setState(() {});
        });
    }
  }

  @override
  void dispose() {
    _videoCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isVideo) {
      if (_videoCtrl == null || !_videoCtrl!.value.isInitialized) {
        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
      }

      return Center(
        child: AspectRatio(
          aspectRatio: _videoCtrl!.value.aspectRatio,
          child: VideoPlayer(_videoCtrl!),
        ),
      );
    }

    // IMAGE
    return Image.network(
      widget.url,
      fit: BoxFit.contain,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, __, ___) {
        return const Center(
          child: Icon(Icons.broken_image, color: Colors.white),
        );
      },
    );
  }
}
