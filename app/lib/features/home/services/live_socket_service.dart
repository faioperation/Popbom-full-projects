import 'package:popbom/app/urls.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class LiveSocketService {
  static final LiveSocketService _instance = LiveSocketService._internal();
  factory LiveSocketService() => _instance;
  LiveSocketService._internal();

  IO.Socket? _socket;

  IO.Socket get socket {
    if (_socket == null) {
      throw Exception("LiveSocketService not connected! Call connect() first.");
    }
    return _socket!;
  }

  bool get isConnected => _socket != null;

  void connect(String token) {
    if (_socket != null) return; // Already connected

    _socket = IO.io(
      Urls.socketBase,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setExtraHeaders({
        'Authorization': 'Bearer $token',
      })
          .build(),
    );

    _socket!.connect();
  }

  void sendComment(String liveId, String message, String username, String photo) {
    if (_socket == null) return;
    _socket!.emit("send-comment", {
      "liveId": liveId,
      "message": message,
      "username": username,
      "photo": photo,
    });
  }

  void sendLike(String liveId) {
    if (_socket == null) return;
    _socket!.emit("send-like", {
      "liveId": liveId,
    });
  }

  void onNewComment(Function(dynamic) callback) {
    if (_socket == null) return;
    _socket!.on("new-comment", callback);
  }

  void onNewLike(Function(dynamic) callback) {
    if (_socket == null) return;
    _socket!.on("new-like", callback);
  }

  void offNewComment() {
    _socket?.off("new-comment");
  }

  void offNewLike() {
    _socket?.off("new-like");
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }
}