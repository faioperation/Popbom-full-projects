import 'package:flutter/material.dart';
import 'package:popbom/features/auth/ui/screen/sign_in_screen.dart';
import 'package:popbom/features/auth/ui/screen/sign_up_screen.dart';
import 'package:popbom/features/auth/ui/widget/app_logo.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _goToSignUpScreen();
    });
  }

  Future<void> _goToSignUpScreen() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SignUpScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: const Column(
              children: [
                Spacer(),
                AppLogo(),
                Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
