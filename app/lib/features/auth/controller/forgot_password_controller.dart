import 'package:get/get.dart';
import 'package:popbom/app/urls.dart';
import 'package:popbom/core/services/network/network_client.dart';

class ForgotPasswordController extends GetxController {
  // Loading state
  bool _inProgress = false;

  // Error state
  String? _errorMessage;

  String? get errorMessage => _errorMessage;
  bool get inProgress => _inProgress;

  /// Send reset password link to user email
  Future<bool> sendResetLink(String email) async {
    bool isSuccess = false;
    _inProgress = true;
    update();


    final NetworkResponse response = await Get.find<NetworkClient>()
        .postRequest(
      Urls.forgotEmailUrl,
      body: {'email': email.trim()},
    );


    if (response.isSuccess) {
      final data = response.responseData;
      final success = data?['success'] ?? false;

      if (success) {
        isSuccess = true;
        _errorMessage = null;
      } else {
        _errorMessage = data?['message'] ?? "Failed to send reset link.";
      }
    } else {
      _errorMessage = response.errorMassage;
    }

    _inProgress = false;
    update();
    return isSuccess;
  }
}
