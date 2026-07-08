import 'package:get/get.dart';
import 'package:popbom/app/urls.dart';
import 'package:popbom/core/services/network/network_client.dart';

class ChallengeDetailsController extends GetxController {
  bool loading = false;
  String? error;

  Map<String, dynamic>? data;

  Future<void> fetchChallenge(String challengeId) async {
    loading = true;
    update();

    try {
      final res = await Get.find<NetworkClient>()
          .getRequest(Urls.getChallengesByChallengeId(challengeId));

      if (res.isSuccess) {
        data = res.responseData?["data"];
      } else {
        error = res.errorMassage ?? "Failed to load challenge";
      }
    } catch (e) {
      error = e.toString();
    }

    loading = false;
    update();
  }
}
