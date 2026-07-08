class Msg {
  final String id;
  final String text;
  final String fromUserId;
  final bool isMe;
  final String createdAt;

  Msg({
    required this.id,
    required this.text,
    required this.fromUserId,
    required this.isMe,
    required this.createdAt,
  });

  factory Msg.fromJson(Map<String, dynamic> json, String myId) {
    final sender = json["senderId"];
    final senderId = sender is Map ? sender["_id"]?.toString() : sender?.toString();

    return Msg(
      id: json["_id"]?.toString() ?? "",
      text: json["text"]?.toString() ?? "",
      fromUserId: senderId ?? "",
      isMe: senderId == myId,
      createdAt: json["createdAt"]?.toString() ?? "",
    );
  }

  // For socket incoming data
  factory Msg.fromServerJson(Map<String, dynamic> json, String myId) {
    final sender = json["senderId"];
    final senderId = sender is Map ? sender["_id"]?.toString() : sender?.toString();

    return Msg(
      id: json["_id"]?.toString() ?? "",
      text: json["text"]?.toString() ?? "",
      fromUserId: senderId ?? "",
      isMe: senderId == myId,
      createdAt: json["createdAt"]?.toString() ?? "",
    );
  }
}
