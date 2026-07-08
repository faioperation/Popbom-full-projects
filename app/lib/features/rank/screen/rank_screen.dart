import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:popbom/features/rank/controller/rank_controller.dart';
import 'package:popbom/features/rank/models/rank_user_model.dart';

class RankScreen extends StatefulWidget {
  final String? challengeId;

  const RankScreen({super.key, this.challengeId});

  @override
  State<RankScreen> createState() => _RankScreenState();
}

class _RankScreenState extends State<RankScreen> {
  final RankController rankCtrl = Get.put(RankController());

  static const Color pillGreen1 = Color(0xff21E6A0);
  static const Color pillGreen2 = Color(0xFF6DF844);

  static const LinearGradient pillGradient = LinearGradient(
    colors: [pillGreen1, pillGreen2],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  @override
  void initState() {
    super.initState();
    rankCtrl.loadRanks(challengeId: widget.challengeId);
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
          style: TextStyle(
            color: fg,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 18,
          ),
        ),
      ),
      body: Obx(() {
        if (rankCtrl.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (rankCtrl.topUsers.isEmpty) {
          return const Center(child: Text("No data found"));
        }

        final users = rankCtrl.topUsers;
        if (users.length < 3)
          return const Center(child: Text("Not enough users"));

        final left = users[1];
        final mid = users[0];
        final right = users[2];
        final others = users.skip(3).toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 70),
                    child: _PodiumTile(user: left, isDark: isDark, big: false),
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
                    child: _PodiumTile(user: right, isDark: isDark, big: false),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            ...others.map(
              (u) => Column(
                children: [
                  _RankRow(user: u, isDark: isDark),
                  Divider(color: isDark ? Colors.white12 : Colors.black12),
                ],
              ),
            ),

            const SizedBox(height: 20),

            if (rankCtrl.loggedUser.value != null) ...[
              Text(
                "Your Rank",
                style: TextStyle(color: fg, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _RankRow(user: rankCtrl.loggedUser.value!, isDark: isDark),
            ],
          ],
        );
      }),
    );
  }
}

/* ================= UI WIDGETS ================= */

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
          backgroundImage: user.avatar.isNotEmpty
              ? CachedNetworkImageProvider(
                  user.avatar,
                  maxHeight: 150,
                  maxWidth: 150,
                )
              : null,
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
            gradient: _RankScreenState.pillGradient,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            child: Text(
              "${user.points} points",
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
            backgroundImage: user.avatar.isNotEmpty
                ? NetworkImage(user.avatar)
                : null,
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
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            "${user.points} pts",
            style: TextStyle(color: fg, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
