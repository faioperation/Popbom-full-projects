import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:popbom/app/urls.dart';
import 'package:popbom/core/services/network/network_client.dart';
import 'package:popbom/features/chat/controller/chat_list_controller.dart';
import 'package:popbom/features/chat/model/msg_model.dart';
import 'package:popbom/features/chat/model/socket.service.dart';
import 'package:popbom/features/common/controllers/auth_controller.dart';

class ChatController extends GetxController {
  final NetworkClient _nc = Get.find<NetworkClient>();
  final AuthController auth = Get.find<AuthController>();

  String? chatId;
  List<Msg> messages = [];
  bool isChatReady = false;
  bool _initialMessagesLoaded = false;

  VoidCallback? onNewMessageCallback;

  Future<NetworkResponse> _get(String url) async => await _nc.getRequest(url);

  Future<NetworkResponse> _post(String url, Map<String, dynamic> body) async =>
      await _nc.postRequest(url, body: body);

  void setChatId(String id) {
    chatId = id;
    isChatReady = true;
    messages.clear();
    _initialMessagesLoaded = false;
    joinChatRoom();
    update();
  }

  void reset() {
    chatId = null;
    isChatReady = false;
    messages.clear();
    update();
  }

  @override
  void onInit() {
    super.onInit();
    _initSocket();
  }

  // Stream subscription to handle incoming messages
  StreamSubscription? _msgSub;

  void _initSocket() {
    if (SocketService.socket == null) return;

    // Remove old listeners just in case, though stream handles it now
    _msgSub?.cancel();

    _msgSub = SocketService.onMessage.listen((data) {
      final convoId = data["conversationId"]?.toString();
      // Only accept messages for THIS specific chat room
      if (convoId != chatId) return;

      final me = auth.userId ?? "";
      final msg = Msg.fromServerJson(data, me);

      messages.add(msg);
      update();
      onNewMessageCallback?.call();
    });

    SocketService.socket!
      ..off("reconnect")
      ..on("reconnect", (_) {
        if (chatId != null) joinChatRoom();
      });
  }

  @override
  void onClose() {
    _msgSub?.cancel();
    super.onClose();
  }

  void joinChatRoom() {
    if (chatId == null || SocketService.socket == null) return;

    SocketService.socket!.emit("join_chat", {"conversationId": chatId});

    debugPrint("🟢 Joined chat room: $chatId");
  }

  Future<void> ensureChatReady(String friendId) async {
    if (chatId != null) return;

    try {
      final res = await _nc.postRequest(
        Urls.startChat,
        body: {"otherUserId": friendId},
      );

      if (!res.isSuccess) return;

      final data = res.responseData?['data'];
      if (data == null) return;
      final id = data['_id']?.toString();
      if (id == null || id.isEmpty) return;
      setChatId(id);

      if (Get.isRegistered<ChatListController>()) {
        Get.find<ChatListController>().loadChatList();
      }
    } catch (e) {
      debugPrint("ensureChatReady error: $e");
    }
  }

  Future<String?> startChat({required String friendId}) async {
    final res = await _nc.postRequest(
      Urls.startChat,
      body: {"otherUserId": friendId},
    );

    if (res.isSuccess) {
      return res.responseData?['data']?['_id']?.toString();
    }

    return null;
  }

  Future<bool> loadMessages() async {
    if (chatId == null || _initialMessagesLoaded) return false;

    final me = auth.userId ?? "";
    final res = await _get(Urls.messages(chatId!));

    if (res.isSuccess) {
      messages = (res.responseData?["data"] as List)
          .map((m) => Msg.fromJson(m, me))
          .toList();

      _initialMessagesLoaded = true;

      update();
      onNewMessageCallback!();
      return true;
    }
    return false;
  }

  Future<bool> sendMessage(String text, String friendId) async {
    if (chatId == null) return false;

    final me = auth.userId ?? "";

    final optimistic = Msg(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      fromUserId: me,
      isMe: true,
      createdAt: DateTime.now().toIso8601String(),
    );

    messages.add(optimistic);
    update();
    onNewMessageCallback?.call();

    SocketService.socket?.emit("send_message", {
      "conversationId": chatId,
      "toUserId": friendId,
      "text": text,
    });

    final res = await _post(Urls.sendMessage, {
      "conversationId": chatId,
      "toUserId": friendId,
      "text": text,
    });

    return res.isSuccess;
  }
}
