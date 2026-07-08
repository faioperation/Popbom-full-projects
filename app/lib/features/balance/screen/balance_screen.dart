import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:popbom/features/balance/screen/cash_out_screen.dart';
import 'package:popbom/features/balance/screen/live_reward_screen.dart';
import 'package:popbom/features/settings/screen/help_center_screen.dart';
import 'package:provider/provider.dart';
import 'package:popbom/theme/theme_provider.dart';

class BalanceScreen extends StatelessWidget {
  const BalanceScreen({super.key});

  static const gradientColors = [Color(0xff21E6A0), Color(0xFF6DF844)];

  final double estimatedBalance = 10.00;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final bgColor = isDark ? Colors.black : Colors.white;
    final appBarFg = isDark ? Colors.white : Colors.black;
    final textColor = appBarFg;
    final cardColor = isDark ? Colors.grey[850]! : Colors.white;
    final lightGreyBorder = isDark ? Colors.transparent : (Colors.grey[300]!);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: Icon(Icons.arrow_back_ios_new, size: 16, color: appBarFg),
        ),
        title: Text(
          'Balance',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: appBarFg),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: [
            Text(
              "Tania’s Balance",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textColor),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: lightGreyBorder),
              ),
              child: Column(
                children: [
                  _tileRow(
                    leading: SvgPicture.asset(
                      'assets/icon/coin.svg',
                      width: 22,
                      height: 22,
                      colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                    ),
                    title: const Text(
                      'Coins',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
                    ),
                    subtitle: const Text(
                      '0',
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                    trailing: _trailingLink('Get coins'),
                  ),
                  Container(
                    height: 1,
                    color: Colors.black.withOpacity(.15),
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  _tileRow(
                    leading: const _LeadingIcon(
                      icon: Icons.account_balance_wallet,
                      size: 22,
                      color: Colors.black87,
                    ),
                    title: const Text(
                      'Estimated balance',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.red),
                    ),
                    subtitle: Text(
                      'USD ${estimatedBalance.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black),
                    ),
                    trailing: _trailingLink('View'), // always black
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Monetization', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textColor)),
                _RightLink(text: 'View more', isDark: isDark),
              ],
            ),
            const SizedBox(height: 10),

            // Gradient tiles (same in all themes)
            _GradientTile(
              svgAsset: "assets/icon/live_rewards.svg", // চাইলে svgAsset: 'assets/icon/live_rewards.svg'
              title: 'Live rewards',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const LiveRewardsScreen()));
              },
              isDark: isDark,
              borderColor: lightGreyBorder,
            ),
            const SizedBox(height: 22),

            Text('Services', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textColor)),
            const SizedBox(height: 10),

            _GradientTile(
              svgAsset: 'assets/icon/transaction.svg', // বা svgAsset: 'assets/icon/transaction.svg'
              title: 'Transaction',
              isDark: isDark,
              borderColor: lightGreyBorder,
            ),
            const SizedBox(height: 12),

            _GradientTile(
              icon: Icons.help_outline, // বা svgAsset: 'assets/icon/help.svg'
              title: 'Help & Support',
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpCenterScreen()));
              },
              isDark: isDark,
              borderColor: lightGreyBorder,
            ),
            const SizedBox(height: 90),

            Center(
              child: InkWell(
                borderRadius: BorderRadius.circular(40),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CashOutScreen(estimatedBalance: estimatedBalance)),
                  );
                },
                child: Ink(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    gradient: const LinearGradient(
                      colors: BalanceScreen.gradientColors,
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    border: Border.all(color: lightGreyBorder),
                  ),
                  child: const Center(
                    child: Text(
                      "Cash out",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black),
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

  static Widget _tileRow({
    required Widget leading,
    required Widget title,
    Widget? subtitle,
    required Widget trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          leading,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                title,
                if (subtitle != null) ...[const SizedBox(height: 4), subtitle],
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  // Always-black trailing link
  static Widget _trailingLink(String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(text, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black)),
        const SizedBox(width: 4),
        const Icon(Icons.chevron_right, color: Colors.black),
      ],
    );
  }
}

// ---------------- Leading icon (no circle background) ----------------
class _LeadingIcon extends StatelessWidget {
  final IconData? icon;      // Material Icon দিলে এটা ইউজ হবে
  final String? svgAsset;    // অথবা SVG asset path
  final double size;         // ভিজ্যুয়াল সাইজ
  final Color? color;        // রঙ

  const _LeadingIcon({
    this.icon,
    this.svgAsset,
    this.size = 22,
    this.color,
  }) : assert(icon != null || svgAsset != null,
  'Provide either icon or svgAsset');

  @override
  Widget build(BuildContext context) {
    final Widget child = svgAsset != null
        ? SvgPicture.asset(
      svgAsset!,
      width: size,
      height: size,
      fit: BoxFit.contain,
      colorFilter: color != null
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
    )
        : Icon(icon, size: size, color: color);

    return SizedBox(
      width: size,
      height: size,
      child: Center(child: child), // নিখুঁত সেন্টার অ্যালাইমেন্ট
    );
  }
}

// Same green gradient in all themes
class _GradientTile extends StatelessWidget {
  final IconData? icon;       // Material icon (optional)
  final String? svgAsset;     // SVG asset path (optional)
  final String title;
  final VoidCallback? onTap;
  final bool isDark;
  final Color? borderColor;

  const _GradientTile({
    this.icon,
    this.svgAsset,
    required this.title,
    this.onTap,
    this.isDark = false,
    this.borderColor,
  }) : assert(icon != null || svgAsset != null,
  'Provide either icon or svgAsset');

  @override
  Widget build(BuildContext context) {
    const gradient = LinearGradient(
      colors: BalanceScreen.gradientColors,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final leading = _LeadingIcon(
      icon: icon,
      svgAsset: svgAsset,
      size: 22,
      color: Colors.black, // গ্রেডিয়েন্ট টাইলের উপর ব্ল্যাক ভালো দেখা যায়
    );

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: gradient,
          border: Border.all(color: borderColor ?? Colors.transparent),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black, // always black on green
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black),
          ],
        ),
      ),
    );
  }
}

class _RightLink extends StatelessWidget {
  final String text;
  final bool isDark;

  const _RightLink({required this.text, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    final color = isDark ? Colors.white : Colors.black;
    return Row(
      children: [
        Text(text, style: TextStyle(fontWeight: FontWeight.w600, color: color)),
        const SizedBox(width: 2),
        Icon(Icons.chevron_right, color: color),
      ],
    );
  }
}
