import 'package:get/get.dart';
import 'package:popbom/app/urls.dart';
import 'package:popbom/core/services/network/network_client.dart';
import 'package:popbom/features/rank/models/rank_user_model.dart';

class ChallengeRankController extends GetxController {
  bool loading = false;
  List<RankUser> ranks = [];

  /// ===============================
  /// 🔹 PARTICIPATED CHALLENGE RANK
  /// ===============================
  Future<void> fetchRank(String challengeId) async {
    loading = true;
    update();

    final res = await Get.find<NetworkClient>()
        .getRequest(Urls.getChallengesRankWhereIParticipant(challengeId));

    if (res.isSuccess) {
      final List data = res.responseData?["data"] ?? [];
      _processParticipants(data);
    }

    loading = false;
    update();
  }

  /// ===============================
  /// 🔹 MY CREATED CHALLENGE RANK
  /// ===============================
  Future<void> fetchMyChallengeRank(String challengeId) async {
    loading = true;
    update();

    final res = await Get.find<NetworkClient>()
        .getRequest(Urls.getMyChallengesAndRank);

    if (res.isSuccess) {
      final List challenges = res.responseData?["data"] ?? [];

      /// 🔍 Find specific challenge by ID
      final challenge = challenges.firstWhere(
            (c) => c["challengeId"] == challengeId,
        orElse: () => null,
      );

      if (challenge != null) {
        final List participants = challenge["participants"] ?? [];
        _processParticipants(participants);
      }
    }

    loading = false;
    update();
  }

  /// ===============================
  /// 🔹 COMMON PROCESSING LOGIC
  /// ===============================
  void _processParticipants(List data) {
    /// 🔥 Sort by watchCount DESC
    data.sort(
          (a, b) => (b["watchCount"] ?? 0).compareTo(a["watchCount"] ?? 0),
    );

    /// 🔥 Max 50 users
    final limited = data.take(50).toList();

    /// 🔥 Generate serial rank (1,2,3...)
    ranks = List.generate(limited.length, (index) {
      final item = limited[index];

      return RankUser(
        rank: index + 1,
        id: item["userId"] ?? item["participantId"] ?? "",
        name: item["name"] ??
            item["userDetails"]?["name"] ??
            "",
        username: item["username"] ??
            item["user"]?["username"] ??
            "",
        avatar: item["photo"] ??
            item["userDetails"]?["photo"] ??
            "",
        points: item["watchCount"] ?? 0,
      );
    });
  }
}
