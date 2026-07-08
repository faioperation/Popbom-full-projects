import 'dart:io';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:popbom/app/urls.dart';
import 'package:popbom/core/services/network/network_client.dart';
import 'package:popbom/features/common/controllers/auth_controller.dart';

class ChallengeCreateController extends GetxController {
  bool _inProgress = false;
  String? _errorMessage;

  bool get inProgress => _inProgress;
  String? get errorMessage => _errorMessage;

  Future<bool> createChallenge({
    required String challengeName,
    required String challengeDesc,
    required List<String> rules,
    required String startDate,
    required String endDate,
    required File poster,
  }) async {
    _inProgress = true;
    update();

    try {
      final auth = Get.find<AuthController>();

      if (auth.accessToken == null || auth.userId == null) {
        await auth.getUserData();
      }

      final token = auth.accessToken;
      final userId = auth.userId;

      if (token == null || userId == null) {
        _errorMessage = "User not logged in!";
        _inProgress = false;
        update();
        return false;
      }

      // -------------------------
      // FIX: Map<String, String>
      // -------------------------
      final Map<String, String> fields = {
        "authorId": userId,
        "challengeName": challengeName,
        "challengeDesc": challengeDesc,
        "challengeStartDate": startDate,
        "challengeEndDate": endDate,

        "rules": jsonEncode(rules),
      };

      final response = await Get.find<NetworkClient>().multipartRequest(
        Urls.createChallenges,
        fields: fields,
        files: {"challengePoster": poster},
        method: "POST",
      );

      if (response.isSuccess) {
        _errorMessage = null;
        _inProgress = false;
        update();
        return true;
      }

      _errorMessage = response.errorMassage ?? "Failed to create challenge!";
    } catch (e) {
      _errorMessage = e.toString();
    }

    _inProgress = false;
    update();
    return false;
  }

}
