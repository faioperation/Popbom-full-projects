import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:popbom/app/urls.dart';
import 'package:popbom/features/common/controllers/auth_controller.dart';

class StoryCreateController extends GetxController {
  bool _inProgress = false;
  String? _errorMessage;

  bool get inProgress => _inProgress;
  String? get errorMessage => _errorMessage;

  Future<bool> uploadStory({
    required File file,
  }) async {
    _inProgress = true;
    update();

    try {
      final auth = Get.find<AuthController>();
      final token = auth.accessToken;

      if (token == null) {
        _errorMessage = "User not logged in!";
        _inProgress = false;
        update();
        return false;
      }

      final uri = Uri.parse(Urls.createStory);
      final request = http.MultipartRequest("POST", uri);

      // REQUIRED FIELDS (backend mandatory)
      request.fields["title"] = "Story";          // auto title
      request.fields["postType"] = "story";       // always story
      request.fields["audience"] = "everyone";    // optional but safe

      // VIDEO FILE (required)
      request.files.add(
        await http.MultipartFile.fromPath(
          "video",
          file.path,
        ),
      );

      request.headers["Authorization"] = "Bearer $token";
      request.headers["Accept"] = "application/json";

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        _errorMessage = null;
        _inProgress = false;
        update();
        return true;
      } else {
        _errorMessage = response.body;
        _inProgress = false;
        update();
        return false;
      }
    } catch (e) {
      _errorMessage = "Something went wrong: $e";
      _inProgress = false;
      update();
      return false;
    }
  }
}
