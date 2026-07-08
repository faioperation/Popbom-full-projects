import 'dart:async';
import 'package:get/get.dart';
import 'package:popbom/app/urls.dart';
import 'package:popbom/core/services/network/network_client.dart';
import 'package:popbom/features/chat/model/socket.service.dart';
import 'package:popbom/features/common/controllers/auth_controller.dart';

class ChatListController extends GetxController {
  final NetworkClient _nc = Get.find<NetworkClient>();
  final AuthController _auth = Get.find<AuthController>();

  bool isLoading = false;
  List<ChatUser> chatList = [];

  Future<NetworkResponse> _get(String url) async => await _nc.getRequest(url);

  // Stream subscription to handle incoming messages
  StreamSubscription? _msgSub;

  void initSocketListeners(String userId, {required String socketUrl}) {
    SocketService.init(userId, socketUrl: socketUrl);

    // Cancel existing subscription if any
    _msgSub?.cancel();

    // Listen to the stream
    _msgSub = SocketService.onMessage.listen((_) {
      loadChatList();
    });

    // Also listen for these events directly since they are global and less frequent
    // Ideally these should also be streams but focusing on message fix first
    SocketService.socket!
      ..off('chat_created')
      ..on('chat_created', (_) => loadChatList())
      ..off('update_last_message')
      ..on('update_last_message', (_) => loadChatList());
  }

  @override
  void onClose() {
    _msgSub?.cancel();
    super.onClose();
  }

  Future<bool> loadChatList({String? currentUserId}) async {
    isLoading = true;
    update();

    final res = await _get(Urls.getAllChatList);

    isLoading = false;

    if (res.isSuccess && res.responseData?['data'] is List) {
      final list = res.responseData!['data'] as List;
      chatList.clear();

      final me = _auth.userId;
      if (me == null || me.isEmpty) {
        update();
        return false;
      }

      for (final c in list) {
        final participants = (c['participants'] as List?) ?? [];

        final friend = participants
            .cast<Map<String, dynamic>>()
            .firstWhereOrNull((x) => x['_id']?.toString() != me);

        if (friend == null) continue;

        final friendId = friend['_id']?.toString() ?? "";
        final friendName = friend['username']?.toString() ?? "";

        String friendPhoto = "";

        final rawPhoto = friend['userDetails']?['photo'];

        if (rawPhoto != null && rawPhoto.toString().startsWith("http")) {
          friendPhoto = rawPhoto.toString();
        }

        chatList.add(
          ChatUser(
            chatId: c['_id']?.toString() ?? "",
            friendId: friendId,
            friendName: friendName,
            friendImage: friendPhoto.isNotEmpty
                ? friendPhoto
                : "https://api.dicebear.com/7.x/initials/png?seed=${Uri.encodeComponent(friendName)}",
            lastMessage: c['lastMessage']?.toString() ?? "",
            time: c['updatedAt']?.toString() ?? "",
          ),
        );
      }

      update();
      return true;
    }

    update();
    return false;
  }
}

class ChatUser {
  final String chatId;
  final String friendId;
  final String friendName;
  final String friendImage;
  final String lastMessage;
  final String time;

  ChatUser({
    required this.chatId,
    required this.friendId,
    required this.friendName,
    required this.friendImage,
    required this.lastMessage,
    required this.time,
  });
}
