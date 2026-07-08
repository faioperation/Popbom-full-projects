import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:image_picker/image_picker.dart';
import 'package:popbom/features/challenge/screen/create_challenge_screen.dart';
import 'package:popbom/features/common/ui/screen/camera_record_screen.dart';
import 'package:popbom/features/home/controller/story_create_controller.dart';
import 'package:popbom/features/home/services/live_sevices.dart';
import 'package:popbom/features/home/ui/screen/live_broadcast_screen.dart';
import 'package:video_player/video_player.dart';

class StoryOrLiveScreen extends StatefulWidget {
  const StoryOrLiveScreen({super.key});

  @override
  State<StoryOrLiveScreen> createState() => _StoryOrLiveScreenState();
}

class _StoryOrLiveScreenState extends State<StoryOrLiveScreen> {
  static const gradientColors = [Color(0xff21E6A0), Color(0xFF6DF844)];
  String? selectedOption; // 'story', 'live', 'post', 'createChallenge'

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final bgColor = isDark ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new, size: 18, color: textColor),
        ),
        title: Text(
          'Create',
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Upper row (Story, Live)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _OptionCard(
                    icon: Icons.slow_motion_video,
                    label: 'Story',
                    color: Colors.pinkAccent,
                    isDark: isDark,
                    isSelected: selectedOption == 'story',
                    onTap: () => setState(() => selectedOption = 'story'),
                  ),
                  _OptionCard(
                    icon: Icons.live_tv,
                    label: 'Live',
                    color: Colors.redAccent,
                    isDark: isDark,
                    isSelected: selectedOption == 'live',
                    onTap: () => setState(() => selectedOption = 'live'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Lower row (Post, Create Challenges)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _OptionCard(
                    icon: Icons.add_photo_alternate_outlined,
                    label: 'Post',
                    color: Colors.redAccent,
                    isDark: isDark,
                    isSelected: selectedOption == 'post',
                    onTap: () => setState(() => selectedOption = 'post'),
                  ),
                  _OptionCard(
                    icon: Icons.add_box_outlined,
                    label: 'Create Challenges',
                    color: Colors.pinkAccent,
                    isDark: isDark,
                    isSelected: selectedOption == 'createChallenge',
                    onTap: () => setState(() => selectedOption = 'createChallenge'),
                  ),
                ],
              ),
            ),
           // const SizedBox(height: 24),
            // Lower row (Post, Create Challenges)
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 32.0),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //     children: [
            //       _OptionCard(
            //         icon: Icons.add_photo_alternate_outlined,
            //         label: 'Ai Creation',
            //         color: Colors.redAccent,
            //         isDark: isDark,
            //         isSelected: selectedOption == 'aiCreation',
            //         onTap: () => setState(() => selectedOption = 'aiCreation'),
            //       ),
            //     ],
            //   ),
            // ),
            const SizedBox(height: 80),
            // Create button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  if (selectedOption == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select an option first!'),
                      ),
                    );
                    return;
                  }
                  switch (selectedOption) {
                    case 'story':
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StoryCameraRecordScreen(cameraIndex: 0,),
                        ),
                      );
                      break;
                    case 'live':
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LiveBroadcastScreen(),
                        ),
                      );
                      break;
                    case 'post':
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CameraRecordScreen(),
                        ),
                      );
                      break;
                    case 'createChallenge':
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CreateChallengeScreen(),
                        ),
                      );
                      break;
                    // case 'aiCreation':
                    //   Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //       builder: (_) => FreeTrialScreen(),
                    //     ),
                    //   );
                    //   break;
                  }
                },
                child: Ink(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Create',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionCard({
    Key? key,
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.15)
              : (isDark ? Colors.grey[900] : const Color(0xFFF3F3F3)),
          borderRadius: BorderRadius.circular(18),
          border: isSelected ? Border.all(color: color, width: 2) : null,
          boxShadow: [
            if (!isDark && !isSelected)
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 5,
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center, // center text horizontally
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center, // text ke center korbe
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}



/// -------------------- CAMERA RECORD SCREEN (FOR STORIES) --------------------
class StoryCameraRecordScreen extends StatefulWidget {
  final int cameraIndex; // 0 = Story, 1 = Live
  const StoryCameraRecordScreen({super.key, required this.cameraIndex});

  @override
  State<StoryCameraRecordScreen> createState() => _StoryCameraRecordScreenState();
}

class _StoryCameraRecordScreenState extends State<StoryCameraRecordScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  List<CameraDescription> _cameras = [];
  CameraController? _controller;
  bool _initializing = true;
  FlashMode _flashMode = FlashMode.auto;
  double _speed = 1.0;
  int _timerSec = 0;

  late final AnimationController _pulse;
  late final AnimationController _blink;
  bool get _isRecording => _controller?.value.isRecordingVideo ?? false;

  Timer? _elapsedTimer;
  Duration _elapsed = Duration.zero;

  // 5 second auto-stop timer
  Timer? _autoStopTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      lowerBound: .9,
      upperBound: 1.15,
    );
    _blink = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _blink.repeat(reverse: true);
    _initCameras();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _elapsedTimer?.cancel();
    _autoStopTimer?.cancel();
    _pulse.dispose();
    _blink.dispose();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initCameras() async {
    try {
      _cameras = await availableCameras();
      if (!mounted) return;
      if (_cameras.isEmpty) return;
      final idx = widget.cameraIndex < _cameras.length ? widget.cameraIndex : 0;
      await _startWith(_cameras[idx]);
    } catch (e) {
      if (!mounted) return;
      print('Camera error: $e');
    }
  }

  Future<void> _startWith(CameraDescription d) async {
    try {
      if (_controller != null) await _controller!.dispose();
    } catch (_) {}
    final c = CameraController(d, ResolutionPreset.high, enableAudio: true);
    _controller = c;
    setState(() => _initializing = true);
    try {
      await c.initialize();
      await c.setFlashMode(_flashMode);
    } catch (e) {
      print('Init error: $e');
    }
    if (!mounted) return;
    setState(() => _initializing = false);
  }

  Future<void> _startOrStopRecording() async {
    final c = _controller;
    if (c == null || !(c.value.isInitialized)) return;

    if (_isRecording) {
      _stopRecording();
      return;
    }

    await c.startVideoRecording();
    _elapsed = Duration.zero;
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _elapsed += const Duration(seconds: 1));
    });

    // Auto stop after 5 seconds
    _autoStopTimer = Timer(const Duration(seconds: 5), () {
      if (_isRecording && mounted) {
        _stopRecording();
      }
    });

    _pulse.repeat(reverse: true);
    setState(() {});
  }

  Future<void> _stopRecording() async {
    _elapsedTimer?.cancel();
    _autoStopTimer?.cancel();
    final file = await _controller!.stopVideoRecording();
    if (!mounted) return;

    // Navigate to preview screen directly after recording
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StoryPreviewScreen(filePath: file.path),
      ),
    );
    setState(() {});
  }

  void _flipCamera() async {
    if (_cameras.length < 2) return;
    final current = _controller!.description;
    final nextIndex = (_cameras.indexOf(current) + 1) % _cameras.length;
    await _startWith(_cameras[nextIndex]);
  }

  void _toggleFlash() async {
    final c = _controller;
    if (c == null) return;
    _flashMode = _flashMode == FlashMode.auto
        ? FlashMode.torch
        : _flashMode == FlashMode.torch
        ? FlashMode.off
        : FlashMode.auto;
    try {
      await c.setFlashMode(_flashMode);
    } catch (_) {
      _flashMode = FlashMode.auto;
    }
    setState(() {});
  }

  void _pickFromGallery() async {
    final x = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (x == null || !mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StoryPreviewScreen(filePath: x.path),
      ),
    );
  }

  Widget _buildCameraPreview() {
    final ctrl = _controller!;
    return CameraPreview(ctrl);
  }

  String _fmtElapsed(Duration d) {
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final onOverlay = dark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: Colors.black,
      body: _initializing || _controller == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          Positioned.fill(child: _buildCameraPreview()),

          // Right rail controls
          Positioned(
            right: 16,
            top: MediaQuery.of(context).size.height * 0.2,
            child: Column(
              children: [
                IconButton(
                  onPressed: _toggleFlash,
                  icon: Icon(
                    _flashMode == FlashMode.auto
                        ? Icons.flash_auto
                        : _flashMode == FlashMode.torch
                        ? Icons.flash_on
                        : Icons.flash_off,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 24),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _speed = _speed == 1.0
                          ? 2.0
                          : _speed == 2.0
                          ? 0.5
                          : 1.0;
                    });
                  },
                  icon: Text(
                    "${_speed}x",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 24),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _timerSec = _timerSec == 0
                          ? 3
                          : _timerSec == 3
                          ? 5
                          : 0;
                    });
                  },
                  icon: Text(
                    _timerSec == 0 ? "0s" : "${_timerSec}s",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          // Bottom controls
          Positioned(
            bottom: 28,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (widget.cameraIndex == 0)
                  InkWell(
                    onTap: _pickFromGallery,
                    child: Column(
                      children: [
                        Icon(Icons.photo_library_outlined,
                            color: onOverlay, size: 32),
                        SizedBox(height: 4),
                        Text('Upload',
                            style: TextStyle(
                                color: onOverlay, fontSize: 12)),
                      ],
                    ),
                  )
                else
                  SizedBox(width: 32),

                GestureDetector(
                  onTap: _startOrStopRecording,
                  child: AnimatedBuilder(
                    animation: _pulse,
                    builder: (_, __) {
                      final scale = _isRecording ? _pulse.value : 1.0;
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 78,
                          height: 78,
                          decoration: BoxDecoration(
                            color:
                            _isRecording ? Colors.redAccent : Colors.white,
                            borderRadius: BorderRadius.circular(_isRecording ? 12 : 999),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                IconButton(
                  onPressed: _flipCamera,
                  icon: Icon(Icons.cameraswitch, color: onOverlay, size: 32),
                ),
              ],
            ),
          ),

          if (_isRecording)
            Positioned(
              top: 50,
              left: 20,
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration:
                    BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                  ),
                  SizedBox(width: 8),
                  Text(_fmtElapsed(_elapsed),
                      style: TextStyle(color: onOverlay, fontSize: 16)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// -------------------- STORY PREVIEW SCREEN --------------------
class StoryPreviewScreen extends StatelessWidget {
  final String filePath;
  StoryPreviewScreen({super.key, required this.filePath});

  final StoryCreateController storyController =
  Get.put(StoryCreateController());

  Future<void> _shareStory(BuildContext context) async {
    final file = File(filePath);

    if (!file.existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Video file missing!")));
      return;
    }

    final ok = await storyController.uploadStory(file: File(filePath),);

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Story uploaded successfully!")),
      );

      Navigator.popUntil(context, (route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            storyController.errorMessage ?? "Story upload failed!",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: VideoPlayerScreen(filePath: filePath),
          ),

          Positioned(
            bottom: 30,
            right: 16,
            child: GetBuilder<StoryCreateController>(
              init: storyController,
              builder: (c) {
                return ElevatedButton(
                  onPressed: c.inProgress ? null : () => _shareStory(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: c.inProgress
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  )
                      : const Text(
                    "Share",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}



/// Minimal Video Player widget
class VideoPlayerScreen extends StatefulWidget {
  final String filePath;
  const VideoPlayerScreen({super.key, required this.filePath});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.filePath))
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
        _controller.setLooping(true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: VideoPlayer(_controller),
    )
        : const Center(child: CircularProgressIndicator());
  }
}