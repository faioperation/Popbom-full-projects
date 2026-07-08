import 'package:get/get.dart';
import 'package:popbom/app/urls.dart';
import 'package:popbom/core/services/network/network_client.dart';

class ForgotPasswordVerifyController extends GetxController {
  bool _inProgress = false;
  String? _errorMessage;

  bool get inProgress => _inProgress;

  String? get errorMessage => _errorMessage;

  /// OTP Verify
  Future<bool> verifyOtp(String email, String otp) async {
    _inProgress = true;
    update();

    bool isSuccess = false;
    try {
      final response = await Get.find<NetworkClient>().postRequest(
        Urls.otpVerifyUrl,
        body: {'email': email, 'otp': otp},
      );

      if (response.isSuccess) {
        final data = response.responseData;
        final success = data?['success'] ?? false;

        if (success) {
          isSuccess = true;
          _errorMessage = null;
        } else {
          _errorMessage = data?['message'] ?? "Invalid OTP";
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

  /// Resend OTP
  Future<bool> resendOtp(String email) async {
    _inProgress = true;
    update();

    bool isSuccess = false;
    try {
      final response = await Get.find<NetworkClient>().postRequest(
        Urls.resendOtpVerifyUrl,
        body: {'email': email},
      );

      if (response.isSuccess) {
        final data = response.responseData;
        final success = data?['success'] ?? false;

        if (success) {
          isSuccess = true;
          _errorMessage = null;
        } else {
          _errorMessage = data?['message'] ?? "Failed to resend OTP";
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
