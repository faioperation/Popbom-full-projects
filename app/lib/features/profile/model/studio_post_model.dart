class StudioPost {
  final String id;
  final String videoUrl;
  final String title;
  final List<String> tags;
  final String views;
  final String likes;

  String? thumbnail; // ✅ NEW (local thumbnail path)

  StudioPost({
    required this.id,
    required this.videoUrl,
    required this.title,
    required this.tags,
    required this.views,
    required this.likes,
    this.thumbnail,
  });

  factory StudioPost.fromTrending(Map<String, dynamic> json) {
    final counts = json['counts'] ?? {};

    return StudioPost(
      id: json['_id']?.toString() ?? '',
      videoUrl: json['videoUrl']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled video',
      tags: const ['#trending'],
      views: '${counts['watchCount'] ?? 0}',
      likes: '${counts['likes'] ?? 0}',
    );
  }

  factory StudioPost.fromRecommended(Map<String, dynamic> json) {
    final meta = json['metadata'] ?? {};
    final counts = meta['counts'] ?? {};

    return StudioPost(
      id: json['post_id']?.toString() ?? '',
      videoUrl: meta['video_url']?.toString() ?? '',
      title: meta['title']?.toString() ?? 'Untitled video',
      tags: List<String>.from(meta['tags'] ?? []),
      views: '${counts['watchCount'] ?? 0}',
      likes: '${counts['likes'] ?? 0}',
    );
  }
}
