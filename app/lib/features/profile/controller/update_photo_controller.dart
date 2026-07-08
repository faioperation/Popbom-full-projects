import 'dart:io';
import 'package:get/get.dart';
import 'package:popbom/app/urls.dart';
import 'package:popbom/core/services/network/network_client.dart';
import 'package:popbom/features/common/controllers/auth_controller.dart';
import 'package:popbom/features/profile/controller/profile_controller.dart';

class UpdatePhotoController extends GetxController {
  bool _inProgress = false;
  String? _errorMessage;

  bool get inProgress => _inProgress;
  String? get errorMessage => _errorMessage;

  Future<bool> updateProfilePhoto(File avatarFile) async {
    _inProgress = true;
    update();

    bool isSuccess = false;

    try {
      final response = await Get.find<NetworkClient>().multipartRequest(
        Urls.updatePhotoUrl,     // /api/users/update-profile-photo
        fields: {},               // No form fields needed
        files: {"photo": avatarFile},
        method: "PATCH",
      );

      if (response.isSuccess) {
        // API returns:
        // { "success": true, "message": "...", "data": "" }

        final profile = Get.find<ProfileController>();
        final auth = Get.find<AuthController>();

        // SERVER returns no new URL, so we keep previous URL
        final oldPhotoUrl = profile.user?.photo;

        // update local user model (temporary)
        if (profile.user != null) {
          profile.user = profile.user!.copyWith(
            photo: oldPhotoUrl ?? "",   // keep server photo, not file path
          );

          profile.update();

          // save to global auth user
          await auth.saveUserData(auth.accessToken, profile.user!);
        }

        isSuccess = true;
        _errorMessage = null;
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
