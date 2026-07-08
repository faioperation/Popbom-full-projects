import 'package:get/get.dart';
import 'package:popbom/app/urls.dart';
import 'package:popbom/core/services/network/network_client.dart';

class GiftController extends GetxController {
  final NetworkClient _nc = Get.find<NetworkClient>();

  // 🔥 Gift count states
  var coins = 0.obs;
  var hearts = 0.obs;
  var roses = 0.obs;
  var stars = 0.obs;
  var fire = 0.obs;

  /// 🎁 Load gift counts for a user
  Future<void> loadGiftCounts(String userId) async {
    final url = Urls.getSingleUserGiftInfo(userId);
    final res = await _nc.getRequest(url);

    if (res.isSuccess) {
      final data = res.responseData?["data"]?["giftCounts"];

      if (data != null) {
        coins.value = data["coin"] ?? 0;
        hearts.value = data["heart"] ?? 0;
        roses.value = data["rose"] ?? 0;
        stars.value = data["star"] ?? 0;
        fire.value = data["fire"] ?? 0;
      }
    }
  }

  /// 🎁 Send Gift
  Future<bool> sendGift({
    required String postId,
    required String giftType,
    required String userId,
    int amount = 1,
  }) async {
    final body = {
      "postId": postId,
      "giftType": giftType,
      "amount": amount,
      "userId": userId,
    };

    final res = await _nc.postRequest(Urls.sendGift, body: body);
    return res.isSuccess;
  }
}
