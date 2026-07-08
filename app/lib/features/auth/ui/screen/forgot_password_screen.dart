import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:popbom/features/auth/controller/forgot_password_controller.dart';
import 'package:popbom/features/common/widget/snack_bar_message.dart';
import 'package:popbom/features/auth/ui/screen/forgot_password_verify_code.dart';
import 'package:popbom/features/auth/ui/widget/app_logo.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final ForgotPasswordController _controller = Get.put(ForgotPasswordController());

  void _sendCode() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final isSuccess = await _controller.sendResetLink(email);

      if (isSuccess) {
        showSnackBarMessage(context, "Password reset link sent to your email");

        // আগের মতো verify code স্ক্রিনে নেভিগেট করা
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ForgotPasswordVerifyCodeScreen(
              email: _emailController.text.trim(), // ✅ make sure this is not empty
            ),
          ),
        );

      } else {
        showSnackBarMessage(
          context,
          _controller.errorMessage ?? "Something went wrong",
          true,
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),

            /// Logo
            const AppLogo(),

            /// Title
            Text(
              "Forgot password?",
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: cs.onBackground,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            /// Subtitle
            Text(
              "Enter your email and we will send you a verification code",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: cs.onBackground.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            /// Email Input
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: "Email",
                  hintStyle: TextStyle(
                    color: cs.onSurface.withOpacity(0.55),
                    fontSize: 16,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  filled: true,
                  fillColor: cs.surface,
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF00E676)),
                    borderRadius: BorderRadius.circular(48),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color(0xFF00E676),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(48),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return "Please enter your email";
                  if (!GetUtils.isEmail(value)) return "Enter a valid email";
                  return null;
                },
              ),
            ),
            const SizedBox(height: 28),

            /// Send Code Button
            GetBuilder<ForgotPasswordController>(
              builder: (controller) {
                return GestureDetector(
                  onTap: controller.inProgress ? null : _sendCode,
                  child: Container(
                    height: 55,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(87),
                      gradient: const LinearGradient(
                        colors: [Color(0xff21E6A0), Color(0xFF6DF844)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: controller.inProgress
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        "Send Code",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
