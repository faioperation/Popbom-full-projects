class PostAuthor {
  String id;
  String username;   // ← NOT final anymore
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
      username: json["username"] ?? details["name"] ?? "",
      name: details["name"],
      photo: details["photo"],
    );
  }
}


/// ⭐ Updated MyPostModel
class MyPostModel {
  final String id; // POST ID
  String? savedRecordId; // ⭐ for unsave
  String? reactionId;
  String? imageUrl;
  String? videoUrl;
  String? thumbnail;

  String title;
  bool isLiked;
  bool isSaved;
  int likeCount;
  int commentCount;
  int watchCount;

  /// ⭐ NEW FIELD → Post Owner (Author)
  PostAuthor? author;

  MyPostModel({
    required this.id,
    this.savedRecordId,
    this.reactionId,
    this.imageUrl,
    this.videoUrl,
    this.thumbnail,
    this.title = "",
    this.isLiked = false,
    this.isSaved = false,
    this.likeCount = 0,
    this.commentCount = 0,
    this.watchCount = 0,
    this.author, // ⭐ ADDED
  });

  factory MyPostModel.fromJson(Map<String, dynamic> json) {
    return MyPostModel(
      id: json["_id"] ?? "",
      savedRecordId: json["savedRecordId"], // optional
      reactionId: json["reactionId"],
      imageUrl: json["imageUrl"],
      videoUrl: json["videoUrl"],
      title: json["title"] ?? "",

      isLiked: json["isLiked"] ?? false,
      isSaved: json["isSaved"] ?? false,

      /// ⭐ counts object (your API sends counts.likes, counts.comments...)
      likeCount: json["counts"]?["likes"] ?? 0,
      commentCount: json["counts"]?["comments"] ?? 0,
      watchCount: json["counts"]?["watchCount"] ?? 0,

      /// ⭐ Parse Author
      author: json["authorId"] != null
          ? PostAuthor.fromJson(json["authorId"])
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
    "id": id,
    "savedRecordId": savedRecordId,
    "reactionId": reactionId,
    "imageUrl": imageUrl,
    "videoUrl": videoUrl,
    "thumbnail": thumbnail,
    "title": title,
    "isLiked": isLiked,
    "isSaved": isSaved,
    "likeCount": likeCount,
    "commentCount": commentCount,
    "watchCount": watchCount,

    /// ⭐ Include author when needed
    "author": author != null
        ? {
      "_id": author!.id,
      "username": author!.username,
      "name": author!.name,
      "photo": author!.photo,
    }
        : null,
  };
}
