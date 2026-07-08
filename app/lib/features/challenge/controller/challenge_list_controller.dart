import 'package:get/get.dart';
import 'package:popbom/app/urls.dart';
import 'package:popbom/core/services/network/network_client.dart';

class ChallengeListController extends GetxController {
  bool loading = false;

  List<dynamic> allChallenges = [];
  List<dynamic> myChallenges = [];
  List<dynamic> participatedChallenges = [];

  String? error;

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

  Future<void> fetchAll() async {
    loading = true;
    update();

    try {
      final res = await Get.find<NetworkClient>().getRequest(Urls.getAllChallenges);

      if (res.isSuccess) {
        final data = res.responseData?["data"] ?? [];

        allChallenges = data
            .map(_processItem)
            .where((item) => !_isExpired(item["challengeEndDate"])) // REMOVE EXPIRED
            .toList();
      } else {
        error = res.errorMassage;
      }
    } catch (e) {
      error = e.toString();
    }

    loading = false;
    update();
  }

  Future<void> fetchMyChallenges() async {
    loading = true;
    update();

    try {
      final res = await Get.find<NetworkClient>().getRequest(Urls.getMyChallenges);

      if (res.isSuccess) {
        final data = res.responseData?["data"] ?? [];

        myChallenges = data
            .map(_processItem)
            .where((item) => !_isExpired(item["challengeEndDate"])) // REMOVE EXPIRED
            .toList();
      } else {
        error = res.errorMassage;
      }
    } catch (e) {
      error = e.toString();
    }

    loading = false;
    update();
  }

  Future<void> fetchParticipated() async {
    loading = true;
    update();

    try {
      final res =
      await Get.find<NetworkClient>().getRequest(Urls.getParticipatedChallenges);

      if (res.isSuccess) {
        final data = res.responseData?["data"] ?? [];

        participatedChallenges = data
            .map(_processItem)
            .toList(); // ❗ DO NOT REMOVE EXPIRED
      } else {
        error = res.errorMassage;
      }
    } catch (e) {
      error = e.toString();
    }

    loading = false;
    update();
  }
}
