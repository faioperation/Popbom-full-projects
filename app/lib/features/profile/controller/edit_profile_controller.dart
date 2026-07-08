import 'dart:io';

import 'package:get/get.dart';
import 'package:popbom/app/urls.dart';
import 'package:popbom/core/services/network/network_client.dart';
import 'package:popbom/features/common/controllers/auth_controller.dart';
import 'package:popbom/features/common/models/user_model.dart';
import 'package:popbom/features/profile/controller/profile_controller.dart';

class EditProfileController extends GetxController {
  bool _inProgress = false;
  String? _errorMessage;

  bool get inProgress => _inProgress;
  String? get errorMessage => _errorMessage;

  String? avatarUrl;

  Future<bool> updateProfile({
    required String originalName,
    required String originalUsername,
    required String originalBio,
    required String originalInstagram,
    required String originalYoutube,
    required String newName,
    required String newUsername,
    required String newBio,
    required String newInstagram,
    required String newYoutube,
    File? avatarFile,
  }) async {
    _inProgress = true;
    update();

    bool isSuccess = false;

    try {
      final Map<String, String> fields = {};

      // Only send changed fields:
      if (newName != originalName) fields['name'] = newName;
      if (newUsername != originalUsername && newUsername.isNotEmpty)
        fields['username'] = newUsername;

      if (newBio != originalBio) fields['bio'] = newBio;
      if (newInstagram != originalInstagram) fields['instagram'] = newInstagram;
      if (newYoutube != originalYoutube) fields['youtube'] = newYoutube;

      // 👉 If no fields changed AND no photo selected → return success
      if (fields.isEmpty && avatarFile == null) {
        _inProgress = false;
        update();
        return true; // nothing to update
      }

      final response = await Get.find<NetworkClient>().multipartRequest(
        Urls.updateProfileUrl,
        fields: fields,
        files: avatarFile != null ? {"photo": avatarFile} : null,
        method: 'PATCH',
      );

      if (response.isSuccess) {
        final data = response.responseData?['data'];

        if (data != null) {
          avatarUrl = data['photo'] ?? avatarUrl;

          final profile = Get.find<ProfileController>();
          profile.user = UserModel.fromJson(data);
          profile.update();

          final auth = Get.find<AuthController>();
          await auth.saveUserData(auth.accessToken ?? "", profile.user!);

          isSuccess = true;
          _errorMessage = null;
        } else {
          _errorMessage = "Profile update failed";
        }
      } else {
        _errorMessage = response.errorMassage;
      }
    } catch (e) {
      _errorMessage = "Something went wrong $e";
    }

    _inProgress = false;
    update();
    return isSuccess;
  }
}
