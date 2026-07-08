import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:popbom/features/profile/controller/studio_controller.dart';
import 'package:popbom/features/profile/model/studio_post_model.dart';
import 'package:popbom/features/settings/screen/settings_screen.dart';
import 'package:provider/provider.dart';
import 'package:popbom/theme/theme_provider.dart';

class StudioScreen extends StatefulWidget {
  const StudioScreen({super.key});

  @override
  State<StudioScreen> createState() => _StudioScreenState();
}

class _StudioScreenState extends State<StudioScreen> {
  final StudioController controller = Get.find<StudioController>();

  Future<void> _refresh() async {
    if (controller.tab == 0) {
      await controller.getTrendingPosts();
    } else {
      await controller.getRecommendedPosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final scaffoldBg = theme.scaffoldBackgroundColor;
    final appBarBg = scaffoldBg;
    final appBarFg = isDark ? Colors.white : Colors.black;

    final onSurface = cs.onSurface;
    final onSurfaceVariant = cs.onSurfaceVariant;
    final surface = theme.cardColor;
    final surfaceVariant = cs.surfaceVariant;
    final greyBorder = isDark ? Colors.transparent : (Colors.grey[300]!);

    const grad = LinearGradient(
      colors: [Color(0xff21E6A0), Color(0xFF6DF844)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: appBarBg,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: appBarFg, size: 18),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          'Studio',
          style: TextStyle(
            color: appBarFg,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: appBarFg, size: 18),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: GetBuilder<StudioController>(
        builder: (_) {
          return RefreshIndicator(
            onRefresh: _refresh,
            color: appBarFg,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              children: [
                /// Analytics card
                Container(
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: greyBorder),
                  ),
                  padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
                  child: Column(
                    children: const [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Analytics',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Icon(Icons.chevron_right),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          _Metric(label: 'Post views', value: '0', delta: '0% 7d'),
                          _Metric(label: 'Net followers', value: '0', delta: '0% 7d'),
                          _Metric(label: 'Likes', value: '0', delta: '0% 7d'),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                /// Tabs
                Container(
                  height: 55,
                  decoration: BoxDecoration(
                    color: surfaceVariant,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: greyBorder),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      _segButton(
                        text: 'Trending',
                        selected: controller.tab == 0,
                        onTap: () => controller.changeTab(0),
                        gradient: grad,
                        surface: surface,
                        onSurface: onSurface,
                        greyBorder: greyBorder,
                      ),
                      _segButton(
                        text: 'Recommended',
                        selected: controller.tab == 1,
                        onTap: () => controller.changeTab(1),
                        gradient: grad,
                        surface: surface,
                        onSurface: onSurface,
                        greyBorder: greyBorder,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                /// Posts
                if (controller.inProgress)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  ),

                ...controller.visiblePosts.map(
                      (p) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _PostRow(
                      post: p,
                      surface: surface,
                      surfaceVariant: surfaceVariant,
                      onSurface: onSurface,
                      onSurfaceVariant: onSurfaceVariant,
                      borderColor: greyBorder,
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

/// ======================= UI WIDGETS =======================

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final String delta;

  const _Metric({
    required this.label,
    required this.value,
    required this.delta,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 6),
          Text(delta, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _PostRow extends StatefulWidget {
  final StudioPost post;
  final Color surface;
  final Color surfaceVariant;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color borderColor;

  const _PostRow({
    required this.post,
    required this.surface,
    required this.surfaceVariant,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.borderColor,
  });

  @override
  State<_PostRow> createState() => _PostRowState();
}

class _PostRowState extends State<_PostRow> {
  bool saved = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: widget.borderColor),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: widget.post.thumbnail != null && File(widget.post.thumbnail!).existsSync()
                ? Image.file(
              File(widget.post.thumbnail!),
              width: 110,
              height: 110,
              fit: BoxFit.cover,
            )
                : Container(
              width: 110,
              height: 110,
              color: widget.surfaceVariant,
              child: Icon(
                Icons.videocam,
                color: widget.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.post.title.isNotEmpty
                      ? widget.post.title
                      : 'Untitled video',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: widget.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.play_circle_outline, size: 18, color: widget.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Text(widget.post.views),
                    const SizedBox(width: 16),
                    Icon(Icons.favorite_border, size: 18, color: widget.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Text(widget.post.likes),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ======================= SEG BUTTON =======================

Widget _segButton({
  required String text,
  required bool selected,
  required VoidCallback onTap,
  required Gradient gradient,
  required Color surface,
  required Color onSurface,
  required Color greyBorder,
}) {
  return Expanded(
    child: DecoratedBox(
      decoration: BoxDecoration(
        gradient: selected ? gradient : null,
        color: selected ? null : surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: selected ? Colors.transparent : greyBorder),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: selected ? Colors.black : onSurface,
        ),
        onPressed: onTap,
        child: Text(text),
      ),
    ),
  );
}
