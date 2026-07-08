import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CombinedFeedScreen extends StatefulWidget {
  const CombinedFeedScreen({super.key});

  @override
  State<CombinedFeedScreen> createState() => _CombinedFeedScreenState();
}

class _CombinedFeedScreenState extends State<CombinedFeedScreen> {
  int tabIndex = 1;
  bool liked = false;
  int likeCount = 250600;

  final tabs = ["LIVE", "STEAM", "Discover", "Following", "Your5"];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // 🔹 top tabs
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                tabs.length,
                (i) => GestureDetector(
                  onTap: () => setState(() => tabIndex = i),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      tabs[i],
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: tabIndex == i ? Colors.black : Colors.black54,
                        decoration: tabIndex == i
                            ? TextDecoration.underline
                            : TextDecoration.none,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: const [
                        CircleAvatar(radius: 32, backgroundColor: Colors.grey),
                        SizedBox(width: 12),
                        CircleAvatar(radius: 32, backgroundColor: Colors.grey),
                        SizedBox(width: 12),
                        CircleAvatar(radius: 32, backgroundColor: Colors.grey),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.pink[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: Colors.brown,
                            radius: 30,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text("Story challenge - 25+ participants"),
                          ),
                          ElevatedButton(
                            onPressed: () {},
                            child: const Text("Join"),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Container(
                    color: Colors.black,
                    height: 500,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.network(
                            "https://images.unsplash.com/photo-1503341455253-b2e723bb3dbb?w=500",
                            fit: BoxFit.cover,
                          ),
                        ),
                        // Play button
                        const Center(
                          child: Icon(
                            Icons.play_circle_fill,
                            size: 72,
                            color: Colors.white70,
                          ),
                        ),

                        // Right side actions
                        Positioned(
                          right: 12,
                          bottom: 100,
                          child: Column(
                            children: [
                              const CircleAvatar(
                                radius: 24,
                                backgroundImage: NetworkImage(
                                  "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=256",
                                ),
                              ),
                              const SizedBox(height: 16),
                              IconButton(
                                icon: Icon(
                                  liked
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: liked ? Colors.pink : Colors.white,
                                  size: 32,
                                ),
                                onPressed: () {
                                  setState(() {
                                    liked = !liked;
                                    likeCount += liked ? 1 : -1;
                                  });
                                },
                              ),
                              Text(
                                "${(likeCount / 1000).toStringAsFixed(1)}K",
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(height: 12),
                              const Icon(
                                Icons.chat_bubble_outline,
                                color: Colors.white,
                                size: 28,
                              ),
                              const SizedBox(height: 12),
                              const Icon(
                                Icons.share,
                                color: Colors.white,
                                size: 28,
                              ),
                              const SizedBox(height: 12),
                              const Icon(
                                Icons.bookmark_border,
                                color: Colors.white,
                                size: 28,
                              ),
                              const SizedBox(height: 12),
                              const Icon(
                                CupertinoIcons.gift,
                                color: Colors.white,
                                size: 28,
                              ),
                            ],
                          ),
                        ),

                        // Bottom caption
                        const Positioned(
                          left: 12,
                          bottom: 12,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Dance24",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "First dance video #viral_dance",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
