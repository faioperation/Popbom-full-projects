import 'dart:io';
import 'package:get/get.dart';
import 'package:popbom/app/urls.dart';
import 'package:popbom/core/services/network/network_client.dart';

class VisualSearchController extends GetxController {
  final NetworkClient _client = Get.find<NetworkClient>();

  RxBool loading = false.obs;
  RxList<dynamic> results = <dynamic>[].obs;


  Map<String, dynamic> _mapVisualResult(dynamic e) {
    final meta = e["metadata"] ?? {};
    final author = meta["authorId"] ?? {};
    final user = author["userDetails"] ?? {};
    final counts = meta["counts"] ?? {};

    return {
      // 🔑 post
      "postId": e["post_id"] ?? "",
      "score": (e["score"] ?? 0).toDouble(),

      // 🎬 media
      "videoUrl": meta["video_url"] ?? "",

      // 👤 user
      "user": {
        "id": author["_id"] ?? "",
        "username": author["username"] ?? "unknown",
        "name": user["name"] ?? author["username"] ?? "Unknown",
        "photo": user["photo"] ?? "",
      },

      // ❤️ counts (NULL SAFE)
      "likes": counts["likes"] ?? 0,
      "comments": counts["comments"] ?? 0,
      "shares": counts["shares"] ?? 0,
      "saved": counts["saved"] ?? 0,
      "watchCount": counts["watchCount"] ?? 0,
    };
  }


  /// 🔤 TEXT SEARCH
  Future<void> searchByText(String query) async {
    loading.value = true;
    results.clear();

    final res = await _client.postRequest(
      Urls.visualSearchByText,
      body: {"query": query},
    );

    if (res.isSuccess) {
      final raw = res.responseData?["data"]?["results"];

      if (raw is List) {
        results.assignAll(raw.map(_mapVisualResult).toList());
      }
    }

    loading.value = false;
  }



  /// 📷 IMAGE SEARCH (FILE)
  /// 📷 IMAGE SEARCH
  Future<void> searchByImage(File image) async {
    loading.value = true;
    results.clear();

    final res = await _client.multipartRequest(
      Urls.visualSearchByImage,
      fields: {},
      files: {
        "image": image, // ✅ backend expects this
      },
    );

    if (res.isSuccess) {
      final raw = res.responseData?["data"]?["results"];
      if (raw is List) {
        results.assignAll(raw.map(_mapVisualResult).toList());
      }
    }

    loading.value = false;
  }

  /// 🎤 AUDIO SEARCH (REAL FILE)
  Future<void> searchByVoice(File audio) async {
    loading.value = true;
    results.clear();

    final res = await _client.multipartRequest(
      Urls.visualSearchByVoice,
      fields: {},
      files: {
        "audio": audio, // ✅ backend expects this
      },
    );

    if (res.isSuccess) {
      final raw = res.responseData?["data"]?["results"];
      if (raw is List) {
        results.assignAll(raw.map(_mapVisualResult).toList());
      }
    }

    loading.value = false;
  }


}
