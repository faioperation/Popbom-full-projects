import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static IO.Socket? socket;
  static final _msgController =
      StreamController<Map<String, dynamic>>.broadcast();

  static Stream<Map<String, dynamic>> get onMessage => _msgController.stream;

  /// Call this once after user login (or when you have userId)
  static void init(String userId, {required String socketUrl}) {
    if (socket != null && socket!.connected) return;

    socket = IO.io(
      socketUrl,
      IO.OptionBuilder().setTransports(['websocket']).enableForceNew().setQuery(
        {"userId": userId},
      ).build(),
    );

    socket!.connect();

    socket!.onConnect((_) => print("🔥 SOCKET CONNECTED"));
    socket!.onDisconnect((_) => print("❌ SOCKET DISCONNECTED"));
    socket!.onError((err) => print("⚠️ SOCKET ERROR: $err"));

    // Listen once and broadcast
    socket!.on("new_message", (data) {
      if (data != null && data is Map<String, dynamic>) {
        _msgController.add(data);
      }
    });
  }

  static void dispose() {
    try {
      socket?.disconnect();
      socket = null;
      // Note: We don't close _msgController here because it's static and might be reused if re-initialized.
      // But if app is fully restarting, it's fine. Ideally, strict lifecycle management needed.
      // For now, keep it open to be safe across re-logins in same session.
    } catch (_) {}
  }
}
