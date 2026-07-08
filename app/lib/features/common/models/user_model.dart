class UserModel {
  final String? id;
  final String? username;
  final String? name;
  final String? email;
  final String? role;
  final String? status;
  final String? bio;
  final String? photo;
  final String? instaLink;
  final String? youtubeLink;
  final String? mobile;

  final String? password;
  final String? passwordResetOTP;
  final String? passwordResetExpires;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  // NEW FIELDS
  int followersCount;
  int followingCount;

  // UI Field
  bool isFollowing;

  /// 🔥 NEW → store following user IDs
  List<String> followingIds;

  UserModel({
    this.id,
    this.username,
    this.name,
    this.email,
    this.role,
    this.status,
    this.bio,
    this.photo,
    this.instaLink,
    this.youtubeLink,
    this.mobile,
    this.password,
    this.passwordResetOTP,
    this.passwordResetExpires,
    this.createdAt,
    this.updatedAt,
    this.isFollowing = false,
    this.followersCount = 0,
    this.followingCount = 0,

    /// NEW
    this.followingIds = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final details = json["details"] ?? {};

    return UserModel(
      id: json["_id"]?.toString() ??
          json["id"]?.toString() ??
          json["userId"]?.toString(),

      username: json["username"],
      email: json["email"],
      role: json["role"],
      status: json["status"],

      // From details
      name: details["name"] ?? json["name"],
      bio: details["bio"] ?? json["bio"],
      photo: details["photo"] ?? json["photo"],

      instaLink: details["instaLink"] ??
          json["instaLink"] ??
          json["instagram"],

      youtubeLink: details["youtubeLink"] ??
          json["youtubeLink"] ??
          json["youtube"],

      mobile: details["mobile"] ?? json["mobile"],

      password: json["password"],
      passwordResetOTP: json["passwordResetOTP"],
      passwordResetExpires: json["passwordResetExpires"],

      createdAt: json["createdAt"] != null
          ? DateTime.tryParse(json["createdAt"])
          : null,

      updatedAt: json["updatedAt"] != null
          ? DateTime.tryParse(json["updatedAt"])
          : null,

      isFollowing: json["isFollowing"] ?? false,

      followersCount: json["followersCount"] ?? 0,
      followingCount: json["followingCount"] ?? 0,

      /// NEW → Load following user IDs
      followingIds: (json["followingIds"] != null)
          ? List<String>.from(json["followingIds"])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "username": username,
      "name": name,
      "email": email,
      "role": role,
      "status": status,
      "bio": bio,
      "photo": photo,
      "instaLink": instaLink,
      "youtubeLink": youtubeLink,
      "mobile": mobile,
      "password": password,
      "passwordResetOTP": passwordResetOTP,
      "passwordResetExpires": passwordResetExpires,
      "createdAt": createdAt?.toIso8601String(),
      "updatedAt": updatedAt?.toIso8601String(),
      "isFollowing": isFollowing,

      "followersCount": followersCount,
      "followingCount": followingCount,

      /// NEW → Save following IDs
      "followingIds": followingIds,
    };
  }

  UserModel copyWith({
    String? id,
    String? username,
    String? name,
    String? email,
    String? role,
    String? status,
    String? bio,
    String? photo,
    String? instaLink,
    String? youtubeLink,
    String? mobile,
    String? password,
    String? passwordResetOTP,
    String? passwordResetExpires,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFollowing,
    int? followersCount,
    int? followingCount,

    /// NEW
    List<String>? followingIds,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      status: status ?? this.status,
      bio: bio ?? this.bio,
      photo: photo ?? this.photo,
      instaLink: instaLink ?? this.instaLink,
      youtubeLink: youtubeLink ?? this.youtubeLink,
      mobile: mobile ?? this.mobile,
      password: password ?? this.password,
      passwordResetOTP: passwordResetOTP ?? this.passwordResetOTP,
      passwordResetExpires:
      passwordResetExpires ?? this.passwordResetExpires,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFollowing: isFollowing ?? this.isFollowing,

      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,

      /// NEW
      followingIds: followingIds ?? this.followingIds,
    );
  }
}
