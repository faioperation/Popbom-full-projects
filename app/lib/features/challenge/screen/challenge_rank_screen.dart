import 'package:flutter/material.dart';
import 'package:popbom/features/common/ui/widgets/centered_circular_progress_indicator.dart';

import '../../rank/models/rank_user_model.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:popbom/features/challenge/controller/challenge_rank_controller.dart';
import '../../rank/models/rank_user_model.dart';

class ChallengeRankScreen extends StatefulWidget {
  final String challengeId;

  const ChallengeRankScreen({super.key, required this.challengeId});

  @override
  State<ChallengeRankScreen> createState() => _ChallengeRankScreenState();
}

class _ChallengeRankScreenState extends State<ChallengeRankScreen> {
  static const Color pillGreen1 = Color(0xff21E6A0);
  static const Color pillGreen2 = Color(0xFF6DF844);

  static const LinearGradient pillGradient = LinearGradient(
    colors: [pillGreen1, pillGreen2],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  late final ChallengeRankController ctrl;

  @override
  void initState() {
    super.initState();
    ctrl = Get.put(ChallengeRankController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final fromMyChallenge =
          Get.arguments != null && Get.arguments["type"] == "my";

      if (fromMyChallenge) {
        ctrl.fetchMyChallengeRank(widget.challengeId);
      } else {
        ctrl.fetchRank(widget.challengeId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? Colors.black : Colors.white;
    final fg = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Rank",
          style: TextStyle(color: fg, fontWeight: FontWeight.w600, fontSize: 16),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
        ),
      ),
      body: GetBuilder<ChallengeRankController>(
        builder: (c) {
          if (c.loading) {
            return const Center(child: CenteredCircularProgressIndicator());
          }

          if (c.ranks.isEmpty) {
            return const Center(child: Text("No ranking data found"));
          }

          final users = c.ranks;

          final mid = users[0];
          final left = users.length > 1 ? users[1] : null;
          final right = users.length > 2 ? users[2] : null;
          final others = users.length > 3 ? users.sublist(3) : [];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 🔝 TOP 3 PODIUM
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 70),
                      child: left == null
                          ? const SizedBox()
                          : _PodiumTile(user: left, isDark: isDark, big: false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PodiumTile(user: mid, isDark: isDark, big: true),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 70),
                      child: right == null
                          ? const SizedBox()
                          : _PodiumTile(user: right, isDark: isDark, big: false),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // 📋 ALL OTHER PARTICIPANTS (SERIAL LIST)
              ...others.map(
                    (u) => Column(
                  children: [
                    _RankRow(user: u, isDark: isDark),
                    Divider(
                      color: isDark ? Colors.white12 : Colors.black12,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}


class _PodiumTile extends StatelessWidget {
  final RankUser user;
  final bool isDark;
  final bool big;

  const _PodiumTile({
    required this.user,
    required this.isDark,
    required this.big,
  });

  @override
  Widget build(BuildContext context) {
    final fg = isDark ? Colors.white : Colors.black;

    return Column(
      children: [
        CircleAvatar(
          radius: big ? 33 : 25,
          child: Text(user.name[0]),
        ),
        const SizedBox(height: 6),
        Text(
          user.name,
          style: TextStyle(color: fg, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Text(
          "${user.rank}th",
          style: TextStyle(
            color: fg,
            fontWeight: FontWeight.bold,
            fontSize: big ? 26 : 20,
          ),
        ),
        const SizedBox(height: 8),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: _ChallengeRankScreenState.pillGradient,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            child: Text(
              "${user.points} view",
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}


class _RankRow extends StatelessWidget {
  final RankUser user;
  final bool isDark;

  const _RankRow({required this.user, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final fg = isDark ? Colors.white : Colors.black;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              "${user.rank}",
              textAlign: TextAlign.center,
              style: TextStyle(color: fg, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 18,
            child: Text(user.name[0]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: TextStyle(color: fg, fontWeight: FontWeight.w700),
                ),
                Text(
                  "@${user.username}",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            "${user.points} view",
            style: TextStyle(color: fg, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

