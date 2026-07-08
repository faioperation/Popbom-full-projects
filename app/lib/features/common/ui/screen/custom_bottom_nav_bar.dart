import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  /// 👉 PLUS button tuning:
  final double plusDx;
  final double plusDy;
  final double plusSize;
  final double centerDy;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.plusDx = -1,
    this.plusDy = 10,
    this.plusSize = 20,
    this.centerDy = -4,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      top: false,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: cs.surface,
          border: Border(
            top: BorderSide(
              color: theme.dividerColor.withOpacity(0.10),
              width: 1.2,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.25 : 0.08),
              blurRadius: 18,
              spreadRadius: 1,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _svgNavItem(context, 'assets/icon/home.svg', "Home", 0),
            _svgNavItem(context, 'assets/icon/person.svg', "Friends", 1),

            // 🔹 Center SVG button (background SVG + plus icon)
            GestureDetector(
              onTap: () => onTap(2),
              child: Transform.translate(
                offset: Offset(0, centerDy),
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      ClipOval(
                        child: SvgPicture.asset(
                          'assets/images/bottom_nav.svg',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Transform.translate(
                        offset: Offset(plusDx, plusDy),
                        child: Icon(
                          Icons.add,
                          size: plusSize,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            _svgNavItem(context, 'assets/icon/inbox.svg', "Inbox", 3),
            _svgNavItem(context, 'assets/icon/person.svg', "Profile", 4),
          ],
        ),
      ),
    );
  }

  /// 🔹 Bottom Nav Item (SVG version)
  Widget _svgNavItem(BuildContext context, String assetPath, String label, int index) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final bool isSelected = currentIndex == index;
    final Color iconColor =
    isSelected ? cs.primary : cs.onSurface.withOpacity(0.7);

    final TextStyle textStyle = TextStyle(
      fontSize: 12,
      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
      color: iconColor,
    );

    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            assetPath,
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),
          const SizedBox(height: 4),
          Text(label, style: textStyle),
        ],
      ),
    );
  }
}
