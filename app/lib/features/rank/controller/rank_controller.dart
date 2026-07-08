import 'package:get/get.dart';
import 'package:popbom/core/services/network/network_client.dart';
import 'package:popbom/app/urls.dart';
import 'package:popbom/features/common/controllers/auth_controller.dart';
import 'package:popbom/features/rank/models/rank_user_model.dart';

class RankController extends GetxController {
  RxBool loading = false.obs;
  RxList<RankUser> topUsers = <RankUser>[].obs;
  Rx<RankUser?> loggedUser = Rx<RankUser?>(null);

  final NetworkClient _client = Get.find<NetworkClient>();
  final AuthController _auth = Get.find<AuthController>();

  Future<void> loadRanks({String? challengeId}) async {
    try {
      loading.value = true;

      if (challengeId != null && challengeId.isNotEmpty) {
        final res = await _client.getRequest(
          Urls.getChallengesRankWhereIParticipant(challengeId),
        );

        if (!res.isSuccess) return;

        final List raw = res.responseData?["data"] ?? [];

        final users = raw.asMap().entries.map((e) {
          final index = e.key;
          final u = e.value;

          return RankUser(
            id: u["participantId"] ?? "",
            name: u["userDetails"]?["name"] ?? "",
            username: u["user"]?["username"] ?? "",
            avatar: u["userDetails"]?["photo"] ?? "",
            points: u["watchCount"] ?? 0,
            rank: index + 1,
          );
        }).toList();

        topUsers.value = users;

        final myId = _auth.userModel?.id ?? "";
        loggedUser.value =
            users.firstWhereOrNull((u) => u.id == myId);

        return;
      }

      final res = await _client.getRequest(Urls.getALlUser);
      if (!res.isSuccess) return;

      final raw = res.responseData?["data"] as List;

      List<RankUser> all = raw.map((u) {
        final d = u["details"] ?? {};

        return RankUser(
          id: u["_id"] ?? "",
          name: d["name"] ?? u["username"] ?? "",
          username: u["username"] ?? "",
          points: u["points"] ?? 0,
          avatar: (d["photo"] != null && d["photo"].toString().isNotEmpty)
              ? d["photo"]
              : "",
          rank: 0,
        );
      }).toList();

      all.sort((a, b) => b.points.compareTo(a.points));

      for (int i = 0; i < all.length; i++) {
        all[i].rank = i + 1;
      }

      final myId = _auth.userModel?.id ?? "";
      loggedUser.value =
          all.firstWhereOrNull((u) => u.id == myId);

      topUsers.value = all.take(50).toList();

    } catch (e) {
      print("Rank Error: $e");
    } finally {
      loading.value = false;
    }
  }
}
