import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:popbom/features/home/controller/visual_search_controller.dart';
import 'package:popbom/features/home/ui/screen/video_feed_screen.dart';

class VisualSearchResultScreen extends StatelessWidget {
  const VisualSearchResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<VisualSearchController>();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppBar(
        backgroundColor: cs.background,
        elevation: 0,
        leading: BackButton(color: cs.onBackground),
        title: Text(
          'Search Results',
          style: TextStyle(color: cs.onBackground),
        ),
      ),
      body: Obx(() {
        if (ctrl.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (ctrl.results.isEmpty) {
          return const Center(
            child: Text(
              "No results found",
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: ctrl.results.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.65,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemBuilder: (_, i) {
            final item = ctrl.results[i];

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VideoFeedScreen(
                      initialIndex: i,
                      searchResults: ctrl.results,
                    ),
                  ),
                );
              },
              child: _ReelCard(
                videoUrl: item["videoUrl"] ?? "",
                likes: item["likes"] ?? 0,
                views: item["watchCount"] ?? 0,
                category: item["user"]?["username"] ?? "",
              ),
            );
          },
        );
      }),
    );
  }
}

class _ReelCard extends StatelessWidget {
  final String videoUrl;
  final int likes;
  final int views;
  final String category;

  const _ReelCard({
    required this.videoUrl,
    required this.likes,
    required this.views,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        children: [
          // Placeholder (future thumbnail)
          Container(color: Colors.black12),

          // Gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Views
          Positioned(
            top: 8,
            right: 8,
            child: Row(
              children: [
                const Icon(Icons.remove_red_eye,
                    size: 16, color: Colors.white),
                const SizedBox(width: 4),
                Text(
                  views.toString(),
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),

          // Likes
          Positioned(
            bottom: 8,
            right: 8,
            child: Row(
              children: [
                const Icon(Icons.favorite,
                    size: 16, color: Colors.white),
                const SizedBox(width: 4),
                Text(
                  likes.toString(),
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),

          // Username
          Positioned(
            left: 8,
            bottom: 8,
            right: 50,
            child: Text(
              category,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
