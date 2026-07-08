class ChallengeRankUser {
  final String id;
  final String name;
  final String username;
  final int points;
  final String avatar;
  int rank;

  ChallengeRankUser({
    required this.id,
    required this.name,
    required this.username,
    required this.points,
    required this.avatar,
    required this.rank,
  });

  factory ChallengeRankUser.fromJson(Map<String, dynamic> json) {
    return ChallengeRankUser(
      id: json['_id'],
      name: json['userDetails']?['name'] ?? '',
      username: json['user']?['username'] ?? '',
      avatar: json['userDetails']?['photo'] ?? '',
      points: json['watchCount'] ?? 0,
      rank: 0, // later calculated
    );
  }
}
