class NotificationModel {
  final String id;
  final String message;
  final String type;
  final String linkType;
  final String linkId;
  bool isRead; // <-- mutable
  final DateTime createdAt;
  final String senderName;
  final String senderAvatar;

  NotificationModel({
    required this.id,
    required this.message,
    required this.type,
    required this.linkType,
    required this.linkId,
    required this.isRead,
    required this.createdAt,
    required this.senderName,
    required this.senderAvatar,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final userDetails = json['senderId']?['userDetails'];

    return NotificationModel(
      id: json['_id'],
      message: json['message'] ?? '',
      type: json['type'] ?? '',
      linkType: json['linkType'] ?? '',
      linkId: json['linkId'] ?? '',
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      senderName: userDetails?['name'] ?? 'Unknown',
      senderAvatar: userDetails?['photo'] ?? '',
    );
  }
}
