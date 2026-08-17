class NewsItem {
  final String title;
  final String? image;
  final String summary;
  final DateTime? date;
  final String? url;
  final String? source;

  NewsItem({
    required this.title,
    this.image,
    required this.summary,
    this.date,
    this.url,
    this.source,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      title: json['title'] ?? '',
      image: json['image'],
      summary: json['summary'] ?? '',
      date: json['date'] != null ? DateTime.tryParse(json['date'].toString()) : null,
      url: json['url'],
      source: json['source'],
    );
  }
}
