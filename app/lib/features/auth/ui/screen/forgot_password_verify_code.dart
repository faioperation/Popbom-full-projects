import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:popbom/features/auth/controller/forgot_password_verify_controller.dart';
import 'package:popbom/features/auth/ui/screen/reset_password_screen.dart';
import 'package:popbom/features/auth/ui/widget/app_logo.dart';

class ForgotPasswordVerifyCodeScreen extends StatefulWidget {
  final String email;

  const ForgotPasswordVerifyCodeScreen({
    super.key,
    required this.email,
  });

  @override
  State<ForgotPasswordVerifyCodeScreen> createState() =>
      _ForgotPasswordVerifyCodeScreenState();
}

class _ForgotPasswordVerifyCodeScreenState
    extends State<ForgotPasswordVerifyCodeScreen> {
  final TextEditingController _otpController = TextEditingController();
  final ForgotPasswordVerifyController _controller =
  Get.put(ForgotPasswordVerifyController());

  Future<void> _verifyCode() async {
    final otp = _otpController.text.trim();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid 6-digit OTP")),
      );
      return;
    }

    final success = await _controller.verifyOtp(widget.email, otp);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Code verified successfully")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResetPasswordScreen(
            email: widget.email,
            otp: otp, // ✅ pass real OTP value
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_controller.errorMessage ?? "Invalid code ❌")),
      );
    }
  }


  Future<void> _resendOtp() async {
    final success = await _controller.resendOtp(widget.email);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🔄 OTP resent successfully")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_controller.errorMessage ?? "Failed to resend OTP"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.background,
      body: GetBuilder<ForgotPasswordVerifyController>(
        builder: (_) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                const AppLogo(),
                Text(
                  "Check your email",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: cs.onBackground,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  "We sent a reset code to\n${widget.email}. Please enter the 6-digit code below.",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: cs.onBackground.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                PinCodeTextField(
                  appContext: context,
                  controller: _otpController,
                  length: 6,
                  keyboardType: TextInputType.number,
                  animationType: AnimationType.fade,
                  enableActiveFill: false,
                  backgroundColor: Colors.transparent,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(8),
                    fieldWidth: 50,
                    fieldHeight: 50,
                    activeColor: const Color(0xFF00E676),
                    selectedColor: const Color(0xFF00E676),
                    inactiveColor: cs.onSurface.withOpacity(0.4),
                  ),
                  onChanged: (_) {},
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _controller.inProgress ? null : _resendOtp,
                  child: const Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "Resend OTP",
                      style: TextStyle(
                        color: Color(0xff21E6A0),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                GestureDetector(
                  onTap: _controller.inProgress ? null : _verifyCode,
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
                      child: _controller.inProgress
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        "Verify Code",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
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
}
