import 'package:get/get.dart';
import 'package:popbom/app/urls.dart';
import 'package:popbom/core/services/network/network_client.dart';
import 'package:popbom/features/auth/data/models/sign_up_request_model.dart';
import 'package:popbom/features/common/controllers/auth_controller.dart';
import 'package:popbom/features/common/models/user_model.dart';

class SignUpController extends GetxController {
  bool _inProgress = false;
  String? _errorMassage;
  String? _message;

  bool get inProgress => _inProgress;
  String? get errorMessage => _errorMassage;
  String? get message => _message;

  Future<bool> signUp(SignUpRequestModel model) async {
    bool isSuccess = false;
    _inProgress = true;
    update();

    final NetworkResponse response =
    await Get.find<NetworkClient>().postRequest(
      Urls.signUpUrl,
      body: model.toJson(),
    );

    if (response.isSuccess) {
      final data = response.responseData;

      // token কন key তে আসবে তা নিশ্চিত করার জন্য
      final token = data?['access_token'] ??
          data?['token'] ??
          data?['accessToken'] ??
          '';

      final userData = data?['data'] ?? data?['user'];

      if (userData != null) {
        // save user + token + userId auto decode
        await Get.find<AuthController>()
            .saveUserData(token, UserModel.fromJson(userData));
      }

      isSuccess = true;
      _errorMassage = null;
    } else {
      _errorMassage = response.errorMassage;
    }

    _inProgress = false;
    update();
    return isSuccess;
  }
}
