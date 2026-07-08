class VideoItem {
  VideoItem({
    required this.id,
    required this.url,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.userFullName,
    required this.caption,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.saves,
    required this.views,
    required this.shareLink,
    this.isLive = false,
    this.liveChannel,
    this.type = "video",
    this.agoraToken,
    this.agoraUid,
    this.commentsList = const [],
    this.reactionId,
    this.isLiked = false,
    this.saved = false,
    this.savedRecordId,
  });

  final String id;
  final String url;
  final String userId;
  final String userName;
  final String userAvatar;
  final String userFullName;
  final String caption;
  int likes;
  int comments;
  int shares;
  int saves;
  int views;
  final String shareLink;

  final bool isLive;
  final String? liveChannel;
  final String type;

  final String? agoraToken;
  final int? agoraUid;

  List<String> commentsList;
  String? reactionId;
  
  bool isLiked;
  bool saved;
  String? savedRecordId;

  VideoItem copyWith({
    String? id,
    String? url,
    String? userId,
    String? userName,
    String? userAvatar,
    String? userFullName,
    String? caption,
    int? likes,
    int? comments,
    int? shares,
    int? saves,
    int? views,
    String? shareLink,
    bool? isLive,
    String? liveChannel,
    String? type,
    String? agoraToken,
    int? agoraUid,
    List<String>? commentsList,
    String? reactionId,
    bool? isLiked,
    String? savedRecordId,
  }) {
    return VideoItem(
      id: id ?? this.id,
      url: url ?? this.url,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      userFullName: userFullName ?? this.userFullName,
      caption: caption ?? this.caption,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      shares: shares ?? this.shares,
      saves: saves ?? this.saves,
      views: views ?? this.views,
      shareLink: shareLink ?? this.shareLink,
      isLive: isLive ?? this.isLive,
      liveChannel: liveChannel ?? this.liveChannel,
      type: type ?? this.type,
      agoraToken: agoraToken ?? this.agoraToken,
      agoraUid: agoraUid ?? this.agoraUid,
      commentsList: commentsList ?? this.commentsList,
      reactionId: reactionId ?? this.reactionId,
      isLiked: isLiked ?? this.isLiked,
      savedRecordId: savedRecordId ?? this.savedRecordId,
    );
  }
}
