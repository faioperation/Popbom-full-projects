import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:popbom/features/auth/controller/sign_in_controller.dart';
import 'package:popbom/features/common/controllers/auth_controller.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:popbom/features/common/widget/snack_bar_message.dart';
import 'package:popbom/features/auth/data/models/sign_in_request_model.dart';
import 'package:popbom/features/auth/ui/widget/app_logo.dart';
import 'package:popbom/features/common/ui/widgets/centered_circular_progress_indicator.dart';
import 'package:popbom/features/home/ui/screen/video_feed_screen.dart';
import 'package:popbom/features/auth/ui/screen/sign_up_screen.dart';
import 'package:popbom/features/auth/ui/screen/forgot_password_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final SignInController _signInController = Get.find<SignInController>();

  bool _rememberMe = false;
  bool _isLoading = false;
  bool _obscurePassword = true;


  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId:
    "549869929938-lr4kpanos55s215qb2q7gc0g2plseo5r.apps.googleusercontent.com",
  );


  @override
  void initState() {
    super.initState();
    _loadRememberMe();
  }

  Future<void> _loadRememberMe() async {
    final auth = Get.find<AuthController>();
    final result = await auth.getRememberMe();

    setState(() {
      _rememberMe = result.$1;

      if (_rememberMe) {
        _emailController.text = result.$2 ?? "";
        _passwordController.text = result.$3 ?? "";
      }
    });
  }




  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    await Get.find<AuthController>().saveRememberMe(
      remember: _rememberMe,
      email: _rememberMe ? _emailController.text.trim() : null,
      password: _rememberMe ? _passwordController.text : null,
    );


    setState(() {
      _isLoading = true;
    });

    final model = SignInRequestModel(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    final bool isSuccess = await _signInController.signIn(model);

    setState(() {
      _isLoading = false;
    });

    if (isSuccess) {
      showSnackBarMessage(context, "Sign In Successful");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => VideoFeedScreen()),
      );
    } else {
      showSnackBarMessage(
        context,
        _signInController.errorMessage ?? "Something went wrong",
        true,
      );
    }
  }


  Future<void> _googleSignInHandler() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;

      if (googleAuth.idToken == null) {
        showSnackBarMessage(context, "Failed to get Google idToken", true);
        return;
      }

      final model = SignInRequestModel(
        provider: "google",
        idToken: googleAuth.idToken,
        email: googleUser.email,
        name: googleUser.displayName,
      );

      final success =
      await _signInController.signIn(model, isSocial: true);

      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => VideoFeedScreen()),
        );
      } else {
        showSnackBarMessage(
            context, _signInController.errorMessage ?? "Login failed", true);
      }
    } catch (e) {
      showSnackBarMessage(context, "Google Sign-In error", true);
    }
  }




  Future<void> _appleSignInHandler() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final model = SignInRequestModel(
        email: credential.email,
        provider: "apple",
        idToken: credential.userIdentifier,
        name:
        "${credential.givenName ?? ''} ${credential.familyName ?? ''}",
      );

      final success =
      await _signInController.signIn(model, isSocial: true);

      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => VideoFeedScreen()),
        );
      } else {
        showSnackBarMessage(
            context, _signInController.errorMessage!, true);
      }
    } catch (e) {
      showSnackBarMessage(context, "Apple Sign-In failed", true);
    }
  }


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            const AppLogo(),
            const SizedBox(height: 16),
            Text(
              "Life, captured in 5",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: cs.onBackground,
              ),
            ),
            const SizedBox(height: 32),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _emailController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Email required";
                      }
                      return null;
                    },
                    decoration: _inputDecoration(context, "Email"),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: _inputDecoration(context, "Password").copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            activeColor: const Color(0xFF21E6A0),
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                            },
                          ),
                          Text(
                            "Remember Me",
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: cs.onBackground,
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: Text(
                          "Forgot password?",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                            color: cs.onBackground,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _isLoading
                      ? const CenteredCircularProgressIndicator()
                      : GestureDetector(
                    onTap: _signIn,
                    child: Container(
                      height: 55,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(87),
                        gradient: const LinearGradient(
                          colors: [Color(0xff21E6A0), Color(0xFF6DF844)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          "Sign in",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _socialButton(
                    icon: "assets/images/google.png",
                    text: "Sign in with Google",
                    onTap: _googleSignInHandler,
                    context: context,
                  ),
                  const SizedBox(height: 12),
                  _socialButton(
                    icon: Icons.apple,
                    text: "Sign in with Apple",
                    onTap: _appleSignInHandler,
                    context: context,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don’t have an account? ",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: cs.onBackground,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignUpScreen()),
                    );
                  },
                  child: const Text(
                    "Sign up",
                    style: TextStyle(color: Color(0xff21E6A0)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(BuildContext context, String hint) {
    final cs = Theme.of(context).colorScheme;
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: cs.onSurface.withOpacity(0.55), fontSize: 16),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF00E676)),
        borderRadius: BorderRadius.circular(48),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF00E676), width: 2),
        borderRadius: BorderRadius.circular(48),
      ),
    );
  }

  Widget _socialButton({
    required BuildContext context,
    required dynamic icon,
    required String text,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;

    Widget leading;
    if (icon is String) {
      leading = Image.asset(icon, height: 24);
    } else if (icon is IconData) {
      leading = Icon(icon, size: 24, color: cs.onBackground);
    } else {
      leading = const SizedBox(width: 24, height: 24);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(48),
        onTap: onTap,
        child: Container(
          height: 50,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              leading,
              const SizedBox(width: 12),
              Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: cs.onBackground,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
