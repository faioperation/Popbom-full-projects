import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:popbom/features/auth/ui/screen/sign_in_screen.dart';
import 'package:popbom/features/balance/screen/balance_screen.dart';
import 'package:popbom/features/common/controllers/auth_controller.dart' show AuthController;
import 'package:popbom/features/qrcode/screen/qr_code_screen.dart';
import 'package:popbom/features/settings/screen/help_center_screen.dart';
import 'package:popbom/features/settings/screen/manage_account_screen.dart';
import 'package:popbom/features/settings/screen/privacy_safety_screen.dart';
import 'package:popbom/features/settings/screen/report_problem_screen.dart';
import 'package:popbom/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // --- shared style helpers ---
  static const _titleStyle = TextStyle(
    fontSize: 15.5,
    fontWeight: FontWeight.w500,
  );

  Widget _sectionHeader(String text, Color textColor) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
    child: Text(
      text.toUpperCase(),
      style: TextStyle(
        color: textColor.withOpacity(0.7),
        fontWeight: FontWeight.w700,
        fontSize: 12,
        letterSpacing: .6,
      ),
    ),
  );

  Widget _tile({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    Widget? trailing,
    required Color iconColor,
    required Color textColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: ListTile(
          leading: Icon(icon, size: 22, color: iconColor),
          title: Text(title, style: _titleStyle.copyWith(color: textColor)),
          trailing: trailing ??
              Icon(Icons.chevron_right, color: textColor.withOpacity(0.5)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          visualDensity: const VisualDensity(vertical: -1),
        ),
      ),
    );
  }

  Widget _card(List<Widget> children) => Container(
    decoration: const BoxDecoration(
      color: Colors.transparent,
    ),
    child: Column(
      children: [
        for (int i = 0; i < children.length; i++) ...[
          children[i],
          if (i != children.length - 1) const SizedBox(height: 1),
        ],
      ],
    ),
  );

  void _open(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode; // <<< থিম স্টেট
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final textColor = Theme.of(context).colorScheme.onBackground;
    final iconColor = textColor.withOpacity(0.87);

    final appBarFg = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: bg,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: appBarFg,size: 18,),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            color: appBarFg,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _sectionHeader('Account', textColor),
          _card([
            _tile(
              icon: Icons.person_outline,
              title: 'Manage my account',
              onTap: () => _open(context, const ManageAccountScreen()),
              iconColor: iconColor,
              textColor: textColor,
            ),
            _tile(
              icon: Icons.light_mode_outlined,
              title: 'Light Mode',
              iconColor: iconColor,
              textColor: textColor,
              trailing: Switch(
                value: themeProvider.isDarkMode,
                activeColor: Colors.white,
                activeTrackColor: const Color(0xFF22C55E),
                onChanged: (v) => themeProvider.toggleTheme(),
              ),
            ),
            // _tile(
            //   icon: Icons.account_balance_wallet_outlined,
            //   title: 'Balance',
            //   onTap: () => _open(context, BalanceScreen()),
            //   iconColor: iconColor,
            //   textColor: textColor,
            // ),
            _tile(
              icon: Icons.ios_share_outlined,
              title: 'Share profile',
              onTap: () => _open(context, QrCodeScreen()),
              iconColor: iconColor,
              textColor: textColor,
            ),
            _tile(
              icon: Icons.qr_code_2_outlined,
              title: 'QR Code',
              onTap: () => _open(context, QrCodeScreen()),
              iconColor: iconColor,
              textColor: textColor,
            ),
          ]),

          // _sectionHeader('General', textColor),
          // _card([
          //   _tile(
          //     icon: Icons.notifications_none,
          //     title: 'Push notifications',
          //     onTap: () => _open(context, PushNotificationsScreen()),
          //     iconColor: iconColor,
          //     textColor: textColor,
          //   ),
          //   _tile(
          //     icon: Icons.language_outlined,
          //     title: 'Language',
          //     onTap: () => _open(context, LanguageScreen()),
          //     iconColor: iconColor,
          //     textColor: textColor,
          //   ),
          // ]),

          _sectionHeader('Support', textColor),
          _card([
            _tile(
              icon: Icons.edit_outlined,
              title: 'Report a problem',
              onTap: () => _open(context, ReportProblemScreen()),
              iconColor: iconColor,
              textColor: textColor,
            ),
            _tile(
              icon: Icons.lock_outline,
              title: 'Privacy and safety',
              onTap: () => _open(context, const PrivacySafetyScreen()),
              iconColor: iconColor,
              textColor: textColor,
            ),
            _tile(
              icon: Icons.help_outline,
              title: 'Help Center',
              onTap: () => _open(context, HelpCenterScreen()),
              iconColor: iconColor,
              textColor: textColor,
            ),

          ]),
          _sectionHeader('Login', textColor),
          _card([
            _tile(
              icon: Icons.logout,
              title: 'Log out',
              iconColor: Colors.redAccent,
              textColor: Colors.redAccent,
              trailing: const SizedBox.shrink(),
              onTap: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) {
                    final bool dark = Theme.of(ctx).brightness == Brightness.dark;
                    final Color dialogBg = dark ? const Color(0xFF1C1F23) : Colors.white;
                    final Color titleColor = dark ? Colors.white : Colors.black;
                    final Color bodyColor  = dark ? Colors.white70 : Colors.black87;

                    return AlertDialog(
                      backgroundColor: dialogBg,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      title: Text('Log out?', style: TextStyle(color: titleColor, fontWeight: FontWeight.w700)),
                      content: Text('Log out of your account?', style: TextStyle(color: bodyColor)),
                      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 18, 20),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: Text('Cancel', style: TextStyle(color: titleColor)),
                        ),

                        // ✅ Gradient confirm button
                        SizedBox(
                          height: 44,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xff21E6A0), Color(0xFF6DF844)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent, // keep gradient visible
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text('Log out',
                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );

                if (ok == true && mounted) {
                  // 1️⃣ clear auth data
                  await Get.find<AuthController>().clearUserData();

                  // 2️⃣ ONLY navigate using GetX (important)
                  Get.offAll(() => const SignInScreen());
                }

              },
            ),
          ])
        ],
      ),
    );
  }
}
