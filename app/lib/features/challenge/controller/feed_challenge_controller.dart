import 'package:get/get.dart';
import 'package:popbom/app/urls.dart';
import 'package:popbom/core/services/network/network_client.dart';

class FeedChallengeController extends GetxController {
  bool loading = false;
  String? error;

  List<dynamic> feedChallenges = [];

  bool _isExpired(String? endDate) {
    if (endDate == null) return false;
    try {
      final d = DateTime.parse(endDate);
      return DateTime.now().isAfter(d);
    } catch (_) {
      return false;
    }
  }

  dynamic _processItem(dynamic item) {
    item["participantsCount"] = (item["participants"] ?? []).length;
    return item;
  }

  Future<void> fetchFeedChallenges() async {
    loading = true;
    error = null;
    update();

    try {
      final res = await Get.find<NetworkClient>().getRequest(
        Urls.getAllChallenges,
      );

      if (res.isSuccess) {
        final data = res.responseData?["data"] ?? [];

        feedChallenges = data
            .map((item) {
              item["participantsCount"] = (item["participants"] ?? []).length;
              return item;
            })
            .where((item) {
              final d = item["challengeEndDate"];
              if (d == null) return true;
              return DateTime.now().isBefore(DateTime.parse(d));
            })
            .toList();

        loading = false;
        update(); // 🔥 SUCCESS UI update
      } else {
        loading = false;
        error = res.errorMassage ?? "Something went wrong";
        update(); // 🔥 ERROR update
      }
    } catch (e) {
      loading = false;
      error = e.toString();
      update(); // 🔥 ERROR update
    }
  }
}
