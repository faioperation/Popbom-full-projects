import 'package:get/get.dart';
import 'package:popbom/app/urls.dart';
import 'package:popbom/core/services/network/network_client.dart';

class ShareProfileController extends GetxController {
  final RxBool loading = false.obs;
  final RxString profileUrl = ''.obs;

  Future<void> fetchShareProfile() async {
    try {
      loading.value = true;

      final res = await Get.find<NetworkClient>()
          .getRequest(Urls.shareProfileUrl);

      if (res.isSuccess) {
        profileUrl.value =
            res.responseData?['data']?['profileUrl'] ?? '';
      }
    } catch (e) {
      profileUrl.value = '';
    } finally {
      loading.value = false;
    }
  }
}
