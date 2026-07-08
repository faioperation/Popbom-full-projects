import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:popbom/features/auth/controller/sign_up_controller.dart';
import 'package:popbom/features/common/widget/snack_bar_message.dart';
import 'package:popbom/features/auth/data/models/sign_up_request_model.dart';
import 'package:popbom/features/auth/ui/screen/sign_in_screen.dart';
import 'package:popbom/features/auth/ui/widget/app_logo.dart';
import 'package:popbom/features/common/ui/widgets/centered_circular_progress_indicator.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final SignUpController _signUpController = Get.find<SignUpController>();

  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      final SignUpRequestModel model = SignUpRequestModel(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      final bool isSuccess = await _signUpController.signUp(model);
      if (isSuccess) {
        showSnackBarMessage(context, "Sign Up Successful");
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SignInScreen()),
        );
      } else {
        showSnackBarMessage(context, _signUpController.errorMessage!, true);
      }
    }
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

            const AppLogo(),

            Text(
              "Welcome to PopBom",
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: cs.onBackground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "PopBom. Explode in 5",
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: cs.onBackground.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Sign up to get started",
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: cs.onBackground,
              ),
            ),
            const SizedBox(height: 32),

            /// Form
            Form(
              key: _formKey,
              child: Column(
                children: [
                  /// Full Name
                  TextFormField(
                    controller: _nameController,
                    decoration: _inputDecoration(context, "Full Name"),
                    // validator: (value) =>
                    //     value!.isEmpty ? "Enter your full name" : null,
                  ),
                  const SizedBox(height: 16),

                  /// Email/Phone
                  TextFormField(
                    controller: _emailController,
                    decoration: _inputDecoration(context, "Email"),
                    // validator: (value) =>
                    //     value!.isEmpty ? "Enter email or phone number" : null,
                  ),
                  const SizedBox(height: 16),

                  /// Phone
                  TextFormField(
                    controller: _phoneController,
                    decoration: _inputDecoration(
                      context,
                      "Phone Number(Optional)",
                    ),
                    // validator: (value) =>
                    //     value!.isEmpty ? "Enter email or phone number" : null,
                  ),
                  const SizedBox(height: 16),

                  /// Password
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
                    validator: (value) => value!.length < 6
                        ? "Password must be at least 6 characters"
                        : null,
                  ),
                  const SizedBox(height: 28),

                  /// Sign Up Button
                  GetBuilder<SignUpController>(
                    builder: (_) {
                      return Visibility(
                        visible: _signUpController.inProgress == false,
                        replacement: CenteredCircularProgressIndicator(),
                        child: GestureDetector(
                          onTap: _signUp,
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
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text(
                                      "Sign up",
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w400,
                                      ),
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
            const SizedBox(height: 30),

            /// Sign in link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Do you have an account? ",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onBackground,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignInScreen()),
                    );
                  },
                  child: const Text(
                    "Sign in",
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

  /// Custom Input Decoration
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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
