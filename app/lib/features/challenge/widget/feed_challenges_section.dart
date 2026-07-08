import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:popbom/features/challenge/screen/challenge_screen.dart';
import 'package:popbom/features/challenge/controller/feed_challenge_controller.dart';
import 'package:popbom/features/challenge/screen/challenge_list_screen.dart';

class FeedChallengesBlock extends StatefulWidget {
  const FeedChallengesBlock();

  @override
  State<FeedChallengesBlock> createState() => _FeedChallengesBlockState();
}

class _FeedChallengesBlockState extends State<FeedChallengesBlock> {
  static const _green1 = Color(0xff21E6A0);
  static const _green2 = Color(0xFF6DF844);

  final FeedChallengeController feedCtrl = Get.find<FeedChallengeController>();

  @override
  void initState() {
    super.initState();
    feedCtrl.fetchFeedChallenges();
  }

  int _chip = 0;
  final _chips = const ['Story', 'Best Joke', 'Workout', 'All Challenges'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final width = MediaQuery.of(context).size.width;
    final cardWidth = width * 0.82;

    final imageWidth = cardWidth - 30;
    final imageHeight = imageWidth * (10 / 16);

    final pinkHeightApprox = 16 + 48 + 8 + 10 + imageHeight + 120;
    final greyHeight = pinkHeightApprox * 1.2;

    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: greyHeight,
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.dark
                ? cs.surface.withOpacity(0.08)
                : const Color(0xFFF4F6F8),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
        ),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Feed Challenges',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: cs.onBackground,
                        ),
                      ),

                      InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChallengeListScreen(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: _green1),
                          ),
                          child: Text(
                            'All Challenges',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 🔹 CHIPS
                  // Wrap(
                  //   spacing: 10,
                  //   runSpacing: 8,
                  //   children: List.generate(_chips.length, (i) {
                  //     final selected = _chip == i;
                  //     return ChoiceChip(
                  //       label: Row(
                  //         mainAxisSize: MainAxisSize.min,
                  //         children: [
                  //           Text(
                  //             _chips[i],
                  //             style: TextStyle(color: cs.onSurface),
                  //           ),
                  //           const SizedBox(width: 6),
                  //           Icon(Icons.link, size: 14, color: cs.onSurface),
                  //         ],
                  //       ),
                  //       selected: selected,
                  //       onSelected: (_) {
                  //         setState(() => _chip = i);
                  //
                  //         if (_chips[i] == 'All Challenges') {
                  //           Navigator.push(
                  //             context,
                  //             MaterialPageRoute(
                  //               builder: (_) => ChallengeListScreen(),
                  //             ),
                  //           );
                  //         }
                  //       },
                  //       backgroundColor: cs.surface,
                  //       selectedColor: cs.surface,
                  //       shape: StadiumBorder(
                  //         side: BorderSide(
                  //           color: selected ? _green1 : const Color(0xFFE0E0E0),
                  //         ),
                  //       ),
                  //     );
                  //   }),
                  // ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            SizedBox(
              height: pinkHeightApprox,
              child: GetBuilder<FeedChallengeController>(
                builder: (c) {
                  if (c.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (c.error != null) {
                    return Center(child: Text(c.error!));
                  }

                  if (c.feedChallenges.isEmpty) {
                    return const Center(child: Text("No challenges found"));
                  }

                  final list = c.feedChallenges;

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 14),
                    itemBuilder: (context, index) {
                      final item = list[index];

                      return _PinkChallengeCard(
                        width: cardWidth,
                        authorName: item["author"]["name"],
                        authorUsername: item["author"]["username"],
                        authorPhoto: item["author"]["photo"],
                        challengeImage: item["challengePoster"],
                        challengeName: item["challengeName"],
                        participants: item["participantsCount"],
                        onJoinTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ChallengeScreen(challengeId: item["_id"]),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PinkChallengeCard extends StatelessWidget {
  final double width;
  final String authorName;
  final String authorUsername;
  final String authorPhoto;
  final String challengeImage;
  final String challengeName;
  final int participants;
  final VoidCallback onJoinTap;

  const _PinkChallengeCard({
    super.key,
    required this.width,
    required this.authorName,
    required this.authorUsername,
    required this.authorPhoto,
    required this.challengeImage,
    required this.challengeName,
    required this.participants,
    required this.onJoinTap,
  });

  static const _green1 = Color(0xff21E6A0);
  static const _green2 = Color(0xFF6DF844);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: width,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE4A5AF), Color(0xFFE7E1DD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Stack(
        children: [
          // 🔹 Author section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(authorPhoto),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authorName,
                        style: textTheme.bodyLarge?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '@$authorUsername',
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: 13,
                          color: cs.onSurface.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 🔹 CHALLENGE POSTER
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 72, 16, 85),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: challengeImage,
                fit: BoxFit.cover,
                width: width,
                memCacheHeight: 400, // Optimize main challenge poster
              ),
            ),
          ),

          // 🔹 Bottom info + Join Button
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: cs.surface.withOpacity(0.95),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          challengeName,
                          style: textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$participants+ participants',
                          style: textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                            color: cs.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: onJoinTap,
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(22)),
                        gradient: LinearGradient(
                          colors: [_green1, _green2],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                      child: const Text(
                        'Join challenge',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
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
