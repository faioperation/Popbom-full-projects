import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:popbom/app/controller_binder.dart';
import 'package:popbom/features/auth/ui/screen/sign_in_screen.dart';
import 'package:popbom/features/common/controllers/auth_controller.dart';
import 'package:popbom/features/profile/controller/profile_controller.dart';
import 'package:popbom/features/home/ui/screen/video_feed_screen.dart';
import 'package:popbom/theme/theme_data.dart';
import 'package:popbom/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class PopBom extends StatefulWidget {
  const PopBom({super.key});

  @override
  State<PopBom> createState() => _PopBomState();
}

class _PopBomState extends State<PopBom> {
  Widget _initialScreen = const Scaffold(
    body: Center(child: CircularProgressIndicator()),
  );

  @override
  void initState() {
    super.initState();
    initialization();
  }

  Future<void> initialization() async {
    // Removed artificial splash delay to improve cold start.
    ControllerBinder().dependencies();

    // Minimal required startup tasks
    final auth = Get.find<AuthController>();
    await auth.getUserData();

    final bool isLoggedIn = await auth.isUserLoggedIn();

    if (isLoggedIn) {
      Get.find<ProfileController>().fetchMyProfile();
    }

    // Determine which screen to show
    setState(() {
      _initialScreen = isLoggedIn ? VideoFeedScreen() : const SignInScreen();
    });

    // Remove native splash
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialBinding: ControllerBinder(),
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: _initialScreen,
    );
  }
}
