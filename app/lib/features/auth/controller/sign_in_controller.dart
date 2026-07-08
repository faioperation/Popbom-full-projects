import 'package:get/get.dart';
import 'package:popbom/app/urls.dart';
import 'package:popbom/core/services/network/network_client.dart';
import 'package:popbom/features/auth/data/models/sign_in_request_model.dart';
import 'package:popbom/features/common/controllers/auth_controller.dart';
import 'package:popbom/features/common/models/user_model.dart';
import 'package:popbom/features/profile/controller/profile_controller.dart';

class SignInController extends GetxController {
  bool _inProgress = false;
  String? _errorMessage;

  bool get inProgress => _inProgress;

  String? get errorMessage => _errorMessage;

  Future<bool> signIn(SignInRequestModel model, {bool isSocial = false}) async {
    _inProgress = true;
    update();

    final response = await Get.find<NetworkClient>().postRequest(
      isSocial
          ? (model.provider == "google"
                ? Urls.googleLoginUrl
                : Urls.appleLoginUrl)
          : Urls.signInUrl,
      retried: true,
      body: model.toJson(),
    );

    _inProgress = false;

    if (response.isSuccess) {
      final inner = response.responseData?["data"];

      final accessToken = inner?["accessToken"] ?? "";
      final refreshToken = inner?["refreshToken"]; // 🔥 NEW (optional)

      if (accessToken.isNotEmpty) {
        await Get.find<AuthController>().saveUserData(
          accessToken,
          UserModel(),
          refreshToken: refreshToken, // 🔥 SAFE
        );

        await Get.find<ProfileController>().fetchMyProfile();
        _errorMessage = null;
        update();
        return true;
      }
    }

    _errorMessage = response.errorMassage ?? "Login failed";
    update();
    return false;
  }
}
