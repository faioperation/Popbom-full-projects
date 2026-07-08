class PostAuthor {
  String id;
  String username;
  String? name;
  String? photo;

  PostAuthor({
    required this.id,
    required this.username,
    this.name,
    this.photo,
  });

  factory PostAuthor.fromJson(Map<String, dynamic> json) {
    final details = json["userDetails"] ?? {};

    return PostAuthor(
      id: json["_id"] ?? "",
      username: json["username"] ?? "",
      name: details["name"],
      photo: details["photo"],
    );
  }
}


class UserPostModel {
  final String id;

  String? videoUrl;
  String? imageUrl;
  String? thumbnail;

  final String? postType;
  final String title;

  int likeCount;
  int commentCount;
  int watchCount;
  int views;

  bool isLiked;
  bool isSaved;

  String? reactionId;
  String? savedRecordId;

  String? date;

  // ⭐ AUTHOR FIELD (MISSING BEFORE)
  PostAuthor? author;

  // Tagged users
  List<String> taggedUsers;

  UserPostModel({
    required this.id,
    this.videoUrl,
    this.imageUrl,
    this.thumbnail,
    this.postType,
    required this.title,

    this.likeCount = 0,
    this.commentCount = 0,
    this.watchCount = 0,
    this.views = 0,

    this.isLiked = false,
    this.isSaved = false,

    this.reactionId,
    this.savedRecordId,

    this.date,

    this.author,   // ⭐ ADD THIS

    this.taggedUsers = const [],
  });

  factory UserPostModel.fromJson(Map<String, dynamic> json) {
    final counts = json["counts"] ?? {};

    return UserPostModel(
      id: json["_id"] ?? "",
      videoUrl: json["videoUrl"],
      imageUrl: json["imageUrl"],
      thumbnail: json["thumbnail"],

      title: json["title"] ?? "",
      postType: json["postType"],
      date: json["createdAt"],

      likeCount: counts["likes"] ?? 0,
      commentCount: counts["comments"] ?? 0,
      watchCount: counts["watchCount"] ?? 0,
      views: counts["watchCount"] ?? 0,

      isLiked: json["isLiked"] ?? false,
      isSaved: json["isSaved"] ?? false,

      reactionId: json["reactionId"],
      savedRecordId: json["savedRecordId"],

      /// ⭐ PARSE AUTHOR HERE
      author: json["authorId"] != null
          ? PostAuthor.fromJson(json["authorId"])
          : null,

      /// ⭐ TAGGED USERS
      taggedUsers: json["taggedPeople"] != null
          ? List<String>.from(json["taggedPeople"].map((u) => u["username"]))
          : [],
    );
  }
}
