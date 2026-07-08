import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:popbom/features/auth/controller/reset_password_controller.dart';
import 'package:popbom/features/auth/ui/screen/reset_successful_screen.dart';
import 'package:popbom/features/auth/ui/widget/app_logo.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email; // ✅ Pass email from previous screen
  final String otp;   // ✅ Pass OTP from verify screen

  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.otp,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _retypePasswordController = TextEditingController();

  final ResetPasswordController _controller = Get.put(ResetPasswordController());

  Future<void> _resetPassword() async {
    final email = widget.email.trim();
    final otp = widget.otp.trim();
    final newPassword = _newPasswordController.text.trim();

    if (email.isEmpty || otp.isEmpty || newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required")),
      );
      return;
    }

    final success = await _controller.resetPassword(
      email: email,
      newPassword: newPassword,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password reset successfully ✅")),
      );
      Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)=>ResetSuccessfulScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_controller.errorMessage ?? "Something went wrong ❌")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.background,
      body: GetBuilder<ResetPasswordController>(
        builder: (_) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                const AppLogo(),
                Text(
                  "Set a new password",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: cs.onBackground,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  "Create a new password. Ensure it differs from previous ones for security.",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    color: cs.onSurface.withOpacity(0.75),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _newPasswordController,
                  obscureText: true,
                  decoration: _inputDecoration(context, "New Password"),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _retypePasswordController,
                  obscureText: true,
                  decoration: _inputDecoration(context, "Retype New Password"),
                ),
                const SizedBox(height: 28),
                GestureDetector(
                  onTap: _controller.inProgress ? null : _resetPassword,
                  child: Container(
                    height: 55,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(87),
                      gradient: LinearGradient(
                        colors: [cs.primary, cs.secondary],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      boxShadow: [
                        if (theme.brightness == Brightness.light)
                          BoxShadow(
                            color: cs.primary.withOpacity(0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                      ],
                    ),
                    child: Center(
                      child: _controller.inProgress
                          ? CircularProgressIndicator(color: cs.onPrimary)
                          : Text(
                        "Reset Password",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: cs.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  InputDecoration _inputDecoration(BuildContext context, String hint) {
    final cs = Theme.of(context).colorScheme;
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: cs.onSurface.withOpacity(0.6),
        fontSize: 16,
      ),
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
}
