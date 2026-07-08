import 'package:flutter/material.dart';
import 'package:popbom/features/auth/ui/screen/sign_in_screen.dart';

class ResetSuccessfulScreen extends StatelessWidget {
  const ResetSuccessfulScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.background, // 🔄 theme-driven
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),

            /// Success Icon
            Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                color: cs.primary, // 🔄
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check,
                color: cs.onPrimary, // 🔄
                size: 60,
              ),
            ),
            const SizedBox(height: 32),

            /// Title
            Text(
              "Password Reset Successfully!",
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: cs.onBackground, // 🔄
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            /// Subtitle
            Text(
              "Your password has been successfully reset.You can\nnow log in with your new password.",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: cs.onSurface.withOpacity(0.75), // 🔄
              ),
              textAlign: TextAlign.center,
            ),

            const Spacer(),
            const SizedBox(height: 28),

            /// Log in Button
            GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const SignInScreen()),
                );
              },
              child: Container(
                height: 55,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(87),
                  gradient: LinearGradient(
                    colors: [cs.primary, cs.secondary], // 🔄 theme-driven gradient
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  boxShadow: [
                    if (theme.brightness == Brightness.light)
                      BoxShadow(
                        color: cs.primary.withOpacity(0.25), // 🔄
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: Center(
                  child: Text(
                    "Log in",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: cs.onPrimary, // 🔄 correct contrast on gradient
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
