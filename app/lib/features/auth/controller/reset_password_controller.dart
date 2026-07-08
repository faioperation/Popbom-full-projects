import 'package:get/get.dart';
import 'package:popbom/app/urls.dart';
import 'package:popbom/core/services/network/network_client.dart';

class ResetPasswordController extends GetxController {
  bool _inProgress = false;
  String? _errorMessage;

  bool get inProgress => _inProgress;
  String? get errorMessage => _errorMessage;

  /// Reset password
  Future<bool> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    _inProgress = true;
    update();

    bool isSuccess = false;

    try {
      final response = await Get.find<NetworkClient>().postRequest(
        Urls.resetPassUrl,
        body: {
          "email": email,
          "newPassword": newPassword, // ✅ matches backend schema
        },
      );

      if (response.isSuccess) {
        final data = response.responseData;
        final success = data?['success'] ?? false;

        if (success) {
          isSuccess = true;
          _errorMessage = null;
        } else {
          _errorMessage = data?['message'] ?? "Failed to reset password";
        }
      } else {
        _errorMessage = response.errorMassage;
      }
    } catch (e) {
      _errorMessage = "Something went wrong: $e";
    }

    _inProgress = false;
    update();
    return isSuccess;
  }
}
