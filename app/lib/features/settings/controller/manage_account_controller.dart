import 'package:get/get.dart';
import 'package:popbom/app/urls.dart';
import 'package:popbom/core/services/network/network_client.dart';
import 'package:popbom/features/common/controllers/auth_controller.dart';
import 'package:popbom/features/common/models/user_model.dart';

class ManageAccountController extends GetxController {
  final NetworkClient _client = Get.find<NetworkClient>();
  final AuthController _auth = Get.find<AuthController>();

  RxBool loading = false.obs;
  RxString error = "".obs;

  UserModel? get user => _auth.userModel;

  Future<bool> updateAccount({
    String? name,
    String? username,
    String? email,
    String? mobile,
    String? currentPassword,
    String? newPassword,
  }) async {
    loading.value = true;
    error.value = "";

    final Map<String, dynamic> body = {};

    if (name != null && name.isNotEmpty) body["name"] = name;
    if (username != null && username.isNotEmpty) body["username"] = username;
    if (email != null && email.isNotEmpty) body["email"] = email;
    if (mobile != null && mobile.isNotEmpty) body["mobile"] = mobile;

    if (currentPassword != null && currentPassword.isNotEmpty) {
      body["currentPassword"] = currentPassword;
    }
    if (newPassword != null && newPassword.isNotEmpty) {
      body["newPassword"] = newPassword;
    }

    final res = await _client.patchRequest(
      Urls.updateProfileWithPassword,
      body: body,
    );

    loading.value = false;

    if (!res.isSuccess) {
      error.value = res.errorMassage ?? "Update failed";
      return false;
    }

    final data = res.responseData?["data"];
    if (data != null) {
      final updated = _auth.userModel?.copyWith(
        name: data["name"],
        username: data["username"],
        email: data["email"],
        mobile: data["mobile"],
      );

      if (updated != null) {
        await _auth.saveUserData(_auth.accessToken!, updated);
      }
    }

    return true;
  }
}
