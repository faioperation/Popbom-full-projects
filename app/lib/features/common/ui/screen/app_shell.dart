import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:popbom/app/urls.dart';
import 'package:popbom/features/chat/model/socket.service.dart';
import 'package:popbom/features/common/controllers/auth_controller.dart';
import 'package:popbom/features/common/ui/screen/camera_record_screen.dart';
import 'package:popbom/features/chat/controller/chat_list_controller.dart';
import 'package:popbom/features/chat/ui/screen/friends_screen.dart';
import 'package:popbom/features/home/ui/screen/home_feed_screen.dart';
import 'package:popbom/features/home/ui/screen/user_profile_friends_screen.dart';
import 'package:popbom/features/profile/screen/profile_screen.dart';
import 'custom_bottom_nav_bar.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, this.initialIndex = 0});
  final int initialIndex;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _index;

  final auth = Get.find<AuthController>();
  final chatListC = Get.find<ChatListController>();

  bool socketInitialized = false;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, 4);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initSocket();
    });
  }


  void _initSocket() {
    if (socketInitialized) return;
    socketInitialized = true;

    final userId = auth.userId;

    if (userId == null || userId.isEmpty) {
      print("⚠️ USER ID NOT READY — socket skipped.");
      return;
    }
    print("🔌 INITIALIZING SOCKET FOR USER: $userId");
    SocketService.init(
      userId,
      socketUrl: Urls.socketBase,
    );
    chatListC.initSocketListeners(
      userId,
      socketUrl: Urls.socketBase,
    );
    print("🔥 SOCKET + CHAT LIST LISTENER READY");
  }

  late final List<Widget> _pages;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pages = [
      const HomeFeedScreen(),
      UserProfileFriendsScreen(userId: auth.userId ?? ""),
      const FriendsScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index >= 2 ? _index - 1 : _index,
        children: _pages,
      ),

      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _index,
        onTap: (i) {
          if (i == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CameraRecordScreen()),
            );
            return;
          }
          setState(() => _index = i);
        },
      ),
    );
  }
}