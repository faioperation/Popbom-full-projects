import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:popbom/features/chat/controller/chat_controller.dart';
import 'package:popbom/features/chat/model/socket.service.dart';
import 'package:popbom/features/common/ui/screen/user_profile_screen.dart';
import 'package:popbom/features/chat/ui/screen/profile_settings_screen.dart';
import 'package:socket_io_client/socket_io_client.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String friendId;
  final String friendName;
  final String friendImage;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.friendId,
    required this.friendName,
    required this.friendImage,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();

  late final ChatController chatC;
  bool _initializingChat = true;


  @override
  void initState() {
    super.initState();

    chatC = Get.find<ChatController>();

    WidgetsBinding.instance.addObserver(this);

    _initChat();
    chatC.onNewMessageCallback = () => _scrollToBottom();
  }


  Future<void> _initChat() async {
    setState(() => _initializingChat = true);

    String? finalChatId;

    if (widget.chatId.isNotEmpty) {
      finalChatId = widget.chatId;
    } else {
      finalChatId = await chatC.startChat(
        friendId: widget.friendId,
      );
    }

    if (finalChatId == null || finalChatId.isEmpty) {
      setState(() => _initializingChat = false);
      return;
    }

    chatC.setChatId(finalChatId);

    if (SocketService.socket?.connected == true) {
      chatC.joinChatRoom();
    } else {
      SocketService.socket?.onConnect((_) {
        chatC.joinChatRoom();
      });
    }

    await chatC.loadMessages();

    setState(() => _initializingChat = false);
  }




  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }


  /// KEYBOARD OPEN/CLOSE LISTENER
  @override
  void didChangeMetrics() {
    Future.delayed(const Duration(milliseconds: 150), () {
      _scrollToBottom();
    });
  }

  /// Always scroll to bottom
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 120), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _goBack() => Navigator.pop(context);

  /// SEND MESSAGE
  void _send() async {
    if (_initializingChat) return;

    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();

    final ok = await chatC.sendMessage(text, widget.friendId);

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Message send failed")),
      );
    }
  }




  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return WillPopScope(
      onWillPop: () async {
        _goBack();
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: cs.background,

        appBar: AppBar(
          backgroundColor: cs.background,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: cs.onBackground,size: 18,),
            onPressed: _goBack,
          ),

          title: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UserProfileScreen(
                    userId: widget.friendId,
                    username: widget.friendName,
                    avatarUrl: widget.friendImage,
                  ),
                ),
              );
            },
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: widget.friendImage.startsWith("http")
                      ? CachedNetworkImageProvider(widget.friendImage,
                          maxHeight: 120, maxWidth: 120)
                      : null,
                  child: !widget.friendImage.startsWith("http")
                      ? Text(
                    widget.friendName.isNotEmpty
                        ? widget.friendName[0].toUpperCase()
                        : "?",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )
                      : null,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.friendName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          actions: [
            IconButton(
              icon: Icon(Icons.info_outline, color: cs.onBackground),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileSettingsPage(
                      userId: widget.friendId,
                      name: widget.friendName,
                      image: widget.friendImage,
                    ),
                  ),
                );
              },
            )
          ],
        ),

        body: Column(
          children: [
            Expanded(
              child: GetBuilder<ChatController>(
                builder: (_) {
                  final msgs = chatC.messages;

                  if (msgs.isEmpty) {
                    return const Center(child: Text("Say Hi 👋"));
                  }

                  return ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: msgs.length,
                    itemBuilder: (context, i) {
                      // last message build হলেই bottom scroll হবে
                      if (i == msgs.length - 1) {
                        Future.microtask(() => _scrollToBottom());
                      }

                      final m = msgs[i];
                      return _chatBubble(m.text, m.isMe, context);
                    },
                  );
                },
              ),
            ),

            _inputField(context),
          ],
        ),
      ),
    );
  }

  /// CHAT BUBBLE
  Widget _chatBubble(String text, bool isMe, BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final bubbleColor = isMe ? cs.primary : cs.surfaceVariant.withOpacity(0.7);
    final textColor = isMe ? cs.onPrimary : cs.onSurface;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(isMe ? 14 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 14),
          ),
        ),
        child: Text(text, style: TextStyle(color: textColor, fontSize: 14.5)),
      ),
    );
  }

  /// INPUT FIELD
  Widget _inputField(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.only(left: 12, right: 12, top: 10, bottom: 10),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: cs.outline.withOpacity(.3))),
        ),

        child: Row(
          children: [
            Expanded(
              child: TextField(
                enabled: !_initializingChat,
                controller: _controller,
                minLines: 1,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Write a message...",
                  filled: true,
                  fillColor: cs.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onTap: _scrollToBottom,
                onSubmitted: (_) => _send(),
              ),
            ),
            const SizedBox(width: 10),

            GestureDetector(
              onTap: _initializingChat ? null : _send,
              child: CircleAvatar(
                radius: 22,
                backgroundColor: _initializingChat
                    ? cs.outline
                    : cs.primary,
                child: Icon(Icons.send_rounded, color: cs.onPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}