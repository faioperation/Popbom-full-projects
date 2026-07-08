import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:popbom/app/urls.dart';

class AgoraTokenResponse {
  final String token;
  final String channel;
  final int uid;

  AgoraTokenResponse({
    required this.token,
    required this.channel,
    required this.uid,
  });
}

class LiveService {
  // ❌ REMOVE static liveId
  // static String? _liveId;

  // ================= START LIVE =================
  static Future<String> startLive({
    required String channel,
    required String bearerToken,
  }) async {
    final res = await http.post(
      Uri.parse(Urls.startLive),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $bearerToken",
      },
      body: jsonEncode({
        "channel": channel,
      }),
    );

    final json = jsonDecode(res.body);

    if (res.statusCode == 201) {
      return json["data"]["_id"];
    } else {
      throw Exception(json["message"] ?? "Start live failed");
    }
  }

  // ================= AGORA TOKEN =================
  static Future<AgoraTokenResponse> getAgoraToken({
    required String channel,
    required bool isBroadcaster,
    required String bearerToken,
  }) async {
    final res = await http.post(
      Uri.parse(Urls.agoraToken),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $bearerToken",
      },
      body: jsonEncode({
        "channel": channel,
        "role": isBroadcaster ? "broadcaster" : "audience",
      }),
    );

    final json = jsonDecode(res.body);

    if (res.statusCode == 200) {
      return AgoraTokenResponse(
        token: json["data"]["token"],
        channel: json["data"]["channel"],
        uid: json["data"]["uid"],
      );
    } else {
      throw Exception(json["message"] ?? "Agora token failed");
    }
  }

  // ================= END LIVE =================
  static Future<void> endLive({
    required String bearerToken,
    required String liveId,
  }) async {
    await http.post(
      Uri.parse(Urls.endLive),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $bearerToken",
      },
      body: jsonEncode({
        "liveId": liveId,
      }),
    );
  }


  // ================= JOIN LIVE (VIEWER) =================
  static Future<void> joinLive({
    required String liveId,
    required String bearerToken,
  }) async {
    try {
      await http.post(
        Uri.parse(Urls.joinLive),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $bearerToken",
        },
        body: jsonEncode({
          "liveId": liveId,
        }),
      );
    } catch (_) {
      // ignore
    }
  }

  // ================= LEAVE LIVE (VIEWER) =================
  static Future<void> leaveLive({
    required String liveId,
    required String bearerToken,
  }) async {
    try {
      await http.post(
        Uri.parse(Urls.leaveLive),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $bearerToken",
        },
        body: jsonEncode({
          "liveId": liveId,
        }),
      );
    } catch (_) {
      // ignore
    }
  }
}
