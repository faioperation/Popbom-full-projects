import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

import 'package:popbom/features/common/controllers/auth_controller.dart';
import 'package:popbom/features/home/services/live_sevices.dart';
import 'package:popbom/features/home/services/live_socket_service.dart';

class LiveBroadcastScreen extends StatefulWidget {
  const LiveBroadcastScreen({super.key});

  @override
  State<LiveBroadcastScreen> createState() => _LiveBroadcastScreenState();
}

class _LiveBroadcastScreenState extends State<LiveBroadcastScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {

  final AuthController authController = Get.find<AuthController>();
  final ScrollController _commentScrollCtrl = ScrollController();

  bool _isLive = false;
  int _viewerCount = 0;
  List<String> _liveComments = [];
  final TextEditingController _commentController = TextEditingController();

  late final AnimationController _pulse;
  Timer? _viewerTimer;
  Timer? _commentTimer;

  late RtcEngine _engine;
  bool _engineInitialized = false;

  final String _appId = "9f667b521f6b4797ba2ab29ec0f9a0e0";
  late String _token;
  late String _channelName;

  late int _agoraUid;
  late String _liveId;

  bool _showHostHeart = false;
  Timer? _heartTimer;


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
      lowerBound: 0.8,
      upperBound: 1.2,
    );

    final token = authController.accessToken;
    if (token != null) {
      LiveSocketService().connect(token);

    }
  }


  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    LiveSocketService().offNewComment();
    LiveSocketService().offNewLike();

    _viewerTimer?.cancel();
    _commentTimer?.cancel();
    _pulse.dispose();

    if (_engineInitialized) {
      _engine.leaveChannel();
      _engine.release();
    }

    _commentController.dispose();
    _commentScrollCtrl.dispose();
    super.dispose();
  }


  void _showHeart() {
    setState(() => _showHostHeart = true);
    _heartTimer?.cancel();
    _heartTimer = Timer(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _showHostHeart = false);
    });
  }


  Widget _buildHostComments() {
    return Positioned(
      left: 16,
      bottom: 120,
      right: 100,
      height: 220,
      child: ListView.builder(
        controller: _commentScrollCtrl,
        itemCount: _liveComments.length,
        itemBuilder: (ctx, i) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              _liveComments[i],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                shadows: [
                  Shadow(color: Colors.black, blurRadius: 4),
                ],
              ),
            ),
          );
        },
      ),
    );
  }


  Widget _buildHostHeart() {
    if (!_showHostHeart) return const SizedBox.shrink();

    return const Positioned(
      right: 40,
      bottom: 200,
      child: Icon(
        Icons.favorite,
        color: Colors.pinkAccent,
        size: 90,
      ),
    );
  }


  Future<bool> _fetchToken() async {
    final user = authController.userModel;
    final userId = authController.userId;
    final bearerToken = authController.accessToken;

    if (user == null || userId == null || bearerToken == null) {
      return false;
    }

    final channel =
        "live_${user.username}_${userId}_${DateTime.now().millisecondsSinceEpoch}";

    _liveId = await LiveService.startLive(
      channel: channel,
      bearerToken: bearerToken,
    );

    final res = await LiveService.getAgoraToken(
      channel: channel,
      isBroadcaster: true,
      bearerToken: bearerToken,
    );

    _token = res.token;
    _channelName = res.channel;
    _agoraUid = res.uid;

    return true;
  }


  Future<bool> _initAgora() async {
    if (_engineInitialized) return true;

    final statuses = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    if (!statuses.values.every((s) => s.isGranted)) return false;

    _engine = createAgoraRtcEngine();

    await _engine.initialize(
      RtcEngineContext(
        appId: _appId,
        channelProfile:
        ChannelProfileType.channelProfileLiveBroadcasting,
      ),
    );

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) {
          debugPrint("✅ Host joined ${connection.channelId}");
        },
        onUserJoined: (connection, uid, elapsed) {
          debugPrint("👀 Viewer joined: $uid");
        },
        onLeaveChannel: (connection, stats) {
          debugPrint("❌ Left channel");
        },
      ),
    );

    await _engine.enableVideo();

    await _engine.setClientRole(
      role: ClientRoleType.clientRoleBroadcaster,
    );

    await _engine.startPreview();

    _engineInitialized = true;
    return true;
  }

  void _scrollHostComments() {
    if (_commentScrollCtrl.hasClients) {
      _commentScrollCtrl.animateTo(
        _commentScrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }


  Future<void> _startLive() async {
    if (_isLive) return;
    LiveSocketService().socket.off("viewer-count");

    try {
      // 🧹 0️⃣ Safety: remove old listeners (VERY IMPORTANT)
      LiveSocketService().offNewComment();
      LiveSocketService().offNewLike();

      // 1️⃣ Backend live create + token
      final tokenOk = await _fetchToken();
      if (!tokenOk) return;

      // 2️⃣ Agora init
      final agoraOk = await _initAgora();
      if (!agoraOk) return;

      // 3️⃣ Join channel as host
      await _engine.joinChannel(
        token: _token,
        channelId: _channelName,
        uid: _agoraUid,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          publishCameraTrack: true,
          publishMicrophoneTrack: true,
        ),
      );

      // 4️⃣ Update UI state
      setState(() {
        _isLive = true;
        _viewerCount = 1;
        _liveComments.clear();
      });

      // 5️⃣ Listen LIVE COMMENTS
      LiveSocketService().onNewComment((data) {
        if (data["liveId"] == _liveId && mounted) {
          setState(() {
            _liveComments.add(
              "${data["username"]}: ${data["message"]}",
            );
          });

          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollHostComments();
          });
        }
      });

      // 6️⃣ Listen LIVE LIKES
      LiveSocketService().onNewLike((data) {
        if (data["liveId"] == _liveId) {
          _showHeart();
        }
      });

      // 7️⃣ Viewer count
      LiveSocketService().socket.on("viewer-count", (data) {
        if (data["liveId"] == _liveId && mounted) {
          setState(() {
            _viewerCount = data["viewerCount"];
          });
        }
      });

      _pulse.repeat(reverse: true);
    } catch (e) {
      debugPrint("❌ Start live failed: $e");
    }
  }



  Future<void> _stopLive() async {
    if (!_isLive) return;

    await _engine.leaveChannel();
    await _engine.stopPreview();

    final bearerToken = authController.accessToken;
    if (bearerToken != null) {
      await LiveService.endLive(
        bearerToken: bearerToken,
        liveId: _liveId,
      );
    }

    setState(() {
      _isLive = false;
      _viewerCount = 0;
      _liveComments.clear();
    });

    _pulse.stop();
  }


  Widget _buildVideoView() {
    if (!_engineInitialized) {
      return const Center(
        child: Text(
          'Initializing camera...',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: _engine,
        canvas: const VideoCanvas(uid: 0),
        useAndroidSurfaceView: true,
      ),
    );
  }


  Widget _buildLiveOverlay() {
    return Stack(
      children: [
        Positioned(
          top: 50,
          left: 20,
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'LIVE',
                style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.people, color: Colors.white, size: 16),
              const SizedBox(width: 4),
              Text(
                '$_viewerCount',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isLive) {
          await _stopLive();
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Positioned.fill(child: _buildVideoView()),
            if (_isLive) _buildLiveOverlay(),
            if (_isLive) _buildHostComments(),
            if (_showHostHeart) _buildHostHeart(),
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: TextButton(
                  onPressed: _isLive ? _stopLive : _startLive,
                  style: TextButton.styleFrom(
                    backgroundColor:
                    _isLive ? Colors.red : Colors.greenAccent,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    _isLive ? 'End Live' : 'Start Live',
                    style: TextStyle(
                      color: _isLive ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 16,
              child: IconButton(
                onPressed: () {
                  if (_isLive) _stopLive();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.close,
                    color: Colors.white, size: 30),
              ),
            ),
          ],
        ),
      ),
    );
  }
}