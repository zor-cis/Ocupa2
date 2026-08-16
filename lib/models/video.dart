class Video {
  final String id;
  final String youtubeId;
  final String url;
  final String title;
  final String description;
  final String? thumbnail;
  final int? order;

  Video({
    required this.id,
    required this.youtubeId,
    required this.url,
    required this.title,
    required this.description,
    this.thumbnail,
    this.order,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'] ?? '',
      youtubeId: json['youtubeId'] ?? '',
      url: json['url'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      thumbnail: json['thumbnail'],
      order: json['order'],
    );
  }
}
