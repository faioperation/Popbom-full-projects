import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:popbom/features/common/ui/screen/templates_screen.dart';
import 'package:video_player/video_player.dart';

import 'video_preview_screen.dart';

class CameraRecordScreen extends StatefulWidget {
  const CameraRecordScreen({super.key, this.challengeId});

  final String? challengeId;

  @override
  State<CameraRecordScreen> createState() => _CameraRecordScreenState();
}

class _CameraRecordScreenState extends State<CameraRecordScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  List<CameraDescription> _cameras = [];
  CameraController? _controller;
  bool _initializing = true;

  FlashMode _flashMode = FlashMode.auto;
  int _timerSec = 0; // pre-record countdown
  double _speed = 1.0;

  bool _countdownVisible = false;
  int _countdown = 0;

  // bottom modes (dynamic)
  final List<({String label, int? duration, bool isTemplates})> _modes =
      const [];
  int _modeIndex = 1; // default -> 15s
  int? get _recordMaxSec => _modes[_modeIndex].duration;

  bool get _isRecording => _controller?.value.isRecordingVideo ?? false;

  Timer? _autoStopTimer;
  Timer? _elapsedTimer;
  Duration _elapsed = Duration.zero;

  // --- Recording visuals ---
  late final AnimationController _pulse; // outer pulse
  late final AnimationController _blink; // small REC blink

  // tiny sound helpers (no extra packages)
  Future<void> _click() async => SystemSound.play(SystemSoundType.click);

  Future<void> _beep() async => SystemSound.play(SystemSoundType.alert);

  void _snack(String msg) {
    if (!mounted) return;
    final cs = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: cs.inverseSurface,
        content: Text(msg, style: TextStyle(color: cs.onInverseSurface)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<bool> requestCameraPermissions() async {
    final statuses = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    return statuses[Permission.camera]?.isGranted == true &&
        statuses[Permission.microphone]?.isGranted == true;
  }

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
    _autoStopTimer?.cancel();
    _elapsedTimer?.cancel();
    try {
      _pulse.dispose();
    } catch (_) {}
    try {
      _blink.dispose();
    } catch (_) {}
    try {
      _controller?.dispose();
    } catch (_) {}
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_controller == null || !_controller!.value.isInitialized) {
        _initCameras();
      }
    }
  }


  Future<void> _initCameras() async {
    final granted = await requestCameraPermissions();
    if (!granted) {
      if (mounted) {
        _snack("Camera & Microphone permission required");
      }
      return;
    }

    try {
      _cameras = await availableCameras();
      if (!mounted) return;

      if (_cameras.isEmpty) {
        setState(() => _initializing = false);
        _snack('No camera found on device');
        return;
      }

      await _startWith(_cameras.first);
    } catch (e) {
      if (!mounted) return;
      setState(() => _initializing = false);
      _snack('Camera error: $e');
    }
  }


  Future<void> _startWith(CameraDescription d) async {
    // Dispose existing controller safely first
    try {
      if (_controller != null) {
        await _controller!.dispose();
        _controller = null;
      }
    } catch (_) {}

    final c = CameraController(
      d,
      ResolutionPreset.high,
      enableAudio: true,
      imageFormatGroup: ImageFormatGroup.yuv420, // more compatible
    );
    _controller = c;
    if (!mounted) return;
    setState(() => _initializing = true);
    try {
      await c.initialize();
      // set initial flash mode (guarded)
      try {
        await c.setFlashMode(_flashMode);
      } catch (_) {}
    } catch (e) {
      if (mounted) _snack('Init error: $e');
    }
    if (!mounted) return;
    setState(() => _initializing = false);
  }

  Future<void> _recreateCurrentCamera() async {
    if (!mounted) return;
    if (_cameras.isEmpty) return;
    final current = _controller?.description;
    final idx = current == null ? 0 : _cameras.indexOf(current);
    final safeIndex = (idx >= 0) ? idx : 0;
    setState(() => _initializing = true);
    await _startWith(_cameras[safeIndex]);
  }

  Future<void> _flipCamera() async {
    await _click();
    if (_cameras.length < 2) return;
    if (_controller == null) {
      // try to start with first available
      await _startWith(_cameras.first);
      return;
    }
    final current = _controller!.description;
    final nextIndex = (_cameras.indexOf(current) + 1) % _cameras.length;
    setState(() => _initializing = true);
    await _startWith(_cameras[nextIndex]);
  }

  Future<void> _toggleFlash() async {
    await _click();
    final c = _controller;
    if (c == null) return;
    // cycle through modes safely
    setState(() {
      _flashMode = _flashMode == FlashMode.auto
          ? FlashMode.torch
          : _flashMode == FlashMode.torch
          ? FlashMode.off
          : FlashMode.auto;
    });
    try {
      await c.setFlashMode(_flashMode);
    } catch (_) {
      // revert to auto if setting fails
      if (mounted) setState(() => _flashMode = FlashMode.auto);
    }
  }

  Future<void> _pickFromGallery() async {
    await _click();
    final x = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (x == null || !mounted) return;

    final file = File(x.path);
    final controller = VideoPlayerController.file(file);
    await controller.initialize();
    final duration = controller.value.duration;
    await controller.dispose();

    if (duration.inSeconds > 5) {
      _snack('Maximum allowed video duration is 5 seconds');
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VideoPreviewScreen(
          filePath: x.path,
          playbackSpeed: _speed,
          challengeId: widget.challengeId,
        ),
      ),
    );
  }

  void _startElapsedTicker() {
    _elapsed = Duration.zero;
    _elapsedTimer?.cancel();
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _elapsed += const Duration(seconds: 1));
      // play a small click but don't await it to avoid blocking the timer/UI
      _click();
    });
  }

  void _stopElapsedTicker() {
    _elapsedTimer?.cancel();
    _elapsedTimer = null;
  }

  Future<void> _startRecordingUI() async {
    HapticFeedback.heavyImpact();
    await _click();
    try {
      _pulse.repeat(reverse: true);
    } catch (_) {}
    _startElapsedTicker();
  }

  Future<void> _stopRecordingUI() async {
    HapticFeedback.mediumImpact();
    await _click();
    try {
      _pulse.stop();
      _pulse.value = 1.0;
    } catch (_) {}
    _stopElapsedTicker();
  }

  Future<void> _startOrStopRecording() async {
    final c = _controller;
    if (c == null || !(c.value.isInitialized)) return;

    // If currently recording -> stop
    if (_isRecording) {
      _autoStopTimer?.cancel();
      await _stopRecordingUI();
      try {
        final file = await c.stopVideoRecording();
        if (!mounted) return;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                VideoPreviewScreen(filePath: file.path, playbackSpeed: _speed,challengeId: widget.challengeId,),
          ),
        );
      } catch (e) {
        if (mounted) _snack('Stop failed: $e');
      }
      if (mounted) setState(() {});
      return;
    }

    // handle pre-record countdown
    if (_timerSec > 0) {
      setState(() {
        _countdownVisible = true;
        _countdown = _timerSec;
      });
      for (var i = _timerSec; i > 0; i--) {
        _beep();
        await Future.delayed(const Duration(seconds: 1));
        if (!mounted) return;
        setState(() => _countdown = i - 1);
      }
      if (!mounted) return;
      setState(() => _countdownVisible = false);
    }

    // start recording
    try {
      final dir = await getTemporaryDirectory();
      final _unusedPath =
          '${dir.path}/rec_${DateTime.now().millisecondsSinceEpoch}.mp4';

      await c.startVideoRecording();
      await _startRecordingUI();

      // ✅ AUTO STOP after 5 seconds
      _autoStopTimer?.cancel();
      _autoStopTimer = Timer(const Duration(seconds: 5), () async {
        if (!mounted) return;
        if (_controller != null && _controller!.value.isRecordingVideo) {
          await _stopRecordingUI();
          try {
            final file = await _controller!.stopVideoRecording();
            if (!mounted) return;
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => VideoPreviewScreen(
                  filePath: file.path,
                  playbackSpeed: _speed,
                  challengeId: widget.challengeId,
                ),
              ),
            );
          } catch (_) {}
          if (mounted) setState(() {});
        }
      });

      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) _snack('Start failed: $e');
    }
  }

  void _selectSpeed() async {
    await _click();
    if (!mounted) return;
    final cs = Theme.of(context).colorScheme;

    final v = await showModalBottomSheet<double>(
      context: context,
      backgroundColor: cs.surface,
      builder: (_) => _SpeedSheet(current: _speed),
    );
    if (v != null && mounted) setState(() => _speed = v);
  }

  void _selectTimer() async {
    await _click();
    if (!mounted) return;
    final cs = Theme.of(context).colorScheme;

    final v = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: cs.surface,
      builder: (_) => _TimerSheet(current: _timerSec),
    );
    if (v != null && mounted) setState(() => _timerSec = v);
  }

  /// Bottom "Templates" pushes TemplatesPage with slide.
  void _onSelectMode(int i) async {
    if (_modes[i].isTemplates) {
      await _click();
      final result = await Navigator.of(context).push<String>(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const TemplatesPage(),
          transitionsBuilder: (_, anim, __, child) {
            final tween = Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeOutCubic));
            return SlideTransition(position: anim.drive(tween), child: child);
          },
        ),
      );
      if (!mounted) return;
      if (result == '15s') {
        setState(() => _modeIndex = 1);
      } else if (result == '60s') {
        setState(() => _modeIndex = 0);
      }
      await _click();
      return;
    }
    setState(() => _modeIndex = i);
    await _click();
  }

  // cover-fit preview
  Widget _buildCameraPreview() {
    final ctrl = _controller!;
    return AspectRatio(
      aspectRatio: ctrl.value.aspectRatio,
      child: CameraPreview(ctrl),
    );
  }


  String _fmtElapsed(Duration d) {
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;

    final onOverlay = dark ? Colors.white : Colors.black;
    final muted = onOverlay.withOpacity(0.7);
    final overlayChip = (dark ? Colors.black : Colors.white).withOpacity(0.28);

    final topInset = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: cs.background,
      resizeToAvoidBottomInset: false,
      body: _initializing || _controller == null
          ? Center(child: CircularProgressIndicator(color: onOverlay))
          : Stack(
              children: [
                const SizedBox.expand(),
                Positioned.fill(child: _buildCameraPreview()),

                // Top bar
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: Icon(Icons.close, color: onOverlay),
                        ),
                        const SizedBox(width: 8),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),

                // Right rail
                Positioned(
                  right: 12,
                  top: topInset + 72,
                  child: DefaultTextStyle(
                    style: TextStyle(color: onOverlay, fontSize: 12),
                    child: Column(
                      children: [
                        _railBtn(
                          'Speed',
                          Icons.speed,
                          _selectSpeed,
                          iconColor: onOverlay,
                          trailing: Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              '${_speed}x',
                              style: TextStyle(color: onOverlay, fontSize: 10),
                            ),
                          ),
                        ),
                        _railBtn(
                          'Timer',
                          Icons.timer,
                          _selectTimer,
                          iconColor: onOverlay,
                          trailing: Text(
                            _timerSec == 0 ? 'off' : '${_timerSec}s',
                            style: TextStyle(color: onOverlay, fontSize: 10),
                          ),
                        ),
                        _railBtn(
                          _flashMode == FlashMode.torch ? 'Torch' : 'Flash',
                          _flashMode == FlashMode.torch
                              ? Icons.highlight
                              : Icons.flash_on,
                          _toggleFlash,
                          iconColor: onOverlay,
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom controls + recording button
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 28,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // dynamic modes
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(_modes.length, (i) {
                            final m = _modes[i];
                            final on = i == _modeIndex && !m.isTemplates;
                            final color = m.isTemplates
                                ? muted
                                : (on ? onOverlay : onOverlay.withOpacity(.54));
                            final style = TextStyle(
                              color: color,
                              fontWeight: on
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            );
                            return Padding(
                              padding: EdgeInsets.only(
                                right: i == _modes.length - 1 ? 0 : 16,
                              ),
                              child: GestureDetector(
                                onTap: () => _onSelectMode(i),
                                child: Text(m.label, style: style),
                              ),
                            );
                          }),
                        ),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // --- BIG RECORD BUTTON (Animated) ---
                          InkWell(
                            onTap: _pickFromGallery,
                            child: Column(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: overlayChip,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.photo_library_outlined,
                                    color: onOverlay,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Upload',
                                  style: TextStyle(color: muted, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: _startOrStopRecording,
                            child: AnimatedBuilder(
                              animation: _pulse,
                              builder: (_, __) {
                                final scale = _isRecording ? _pulse.value : 1.0;
                                return Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // pulsing ring when recording
                                    Transform.scale(
                                      scale: scale,
                                      child: Container(
                                        width: 90,
                                        height: 90,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: _isRecording
                                              ? Colors.red.withOpacity(
                                                  dark ? 0.25 : 0.18,
                                                )
                                              : Colors.transparent,
                                          border: Border.all(
                                            color: onOverlay.withOpacity(.7),
                                            width: 4,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 78,
                                      height: 78,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        curve: Curves.easeOut,
                                        width: _isRecording ? 44 : 62,
                                        height: _isRecording ? 44 : 62,
                                        decoration: BoxDecoration(
                                          color: Colors.redAccent,
                                          borderRadius: BorderRadius.circular(
                                            _isRecording ? 10 : 999,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          _railBtn(
                            'Flip',
                            Icons.cameraswitch,
                            _flipCamera,
                            iconColor: onOverlay,
                          ),
                        ],
                      ),

                      if (_isRecording) ...[
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FadeTransition(
                              opacity: _blink.drive(
                                CurveTween(curve: Curves.easeIn),
                              ),
                              child: Container(
                                width: 12, // slightly larger for visibility
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: Colors.redAccent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _fmtElapsed(_elapsed),
                              style: TextStyle(color: onOverlay, fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                if (_countdownVisible)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black38,
                      child: Center(
                        child: Text(
                          '$_countdown',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 88,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _railBtn(
    String label,
    IconData icon,
    VoidCallback onTap, {
    Widget? trailing,
    Color? iconColor,
  }) {
    final theme = Theme.of(context);
    final onOverlay = theme.brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Icon(icon, color: iconColor ?? onOverlay, size: 28),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: onOverlay, fontSize: 12)),
            if (trailing != null) ...[const SizedBox(height: 2), trailing],
          ],
        ),
      ),
    );
  }
}

// --- sheets ---
class _SpeedSheet extends StatelessWidget {
  const _SpeedSheet({required this.current});

  final double current;

  @override
  Widget build(BuildContext context) {
    final options = [0.5, 1.0, 2.0];
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: options
            .map(
              (v) => ListTile(
                title: Text('${v}x', style: TextStyle(color: cs.onSurface)),
                trailing: current == v ? const Icon(Icons.check) : null,
                onTap: () => Navigator.pop(context, v),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _TimerSheet extends StatelessWidget {
  const _TimerSheet({required this.current});

  final int current;

  @override
  Widget build(BuildContext context) {
    final options = [0, 3, 10];
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: options
            .map(
              (v) => ListTile(
                title: Text(
                  v == 0 ? 'Off' : '${v}s',
                  style: TextStyle(color: cs.onSurface),
                ),
                trailing: current == v ? const Icon(Icons.check) : null,
                onTap: () => Navigator.pop(context, v),
              ),
            )
            .toList(),
      ),
    );
  }
}
