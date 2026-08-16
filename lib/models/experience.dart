class Experience {
  final String id;
  final String title;
  final String description;
  final String? jobTypeKey;
  final String? certificateImage;

  Experience({
    required this.id,
    required this.title,
    required this.description,
    this.jobTypeKey,
    this.certificateImage,
  });

  factory Experience.fromJson(Map<String, dynamic> json) {
    return Experience(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      jobTypeKey: json['jobTypeKey'],
      certificateImage: json['certificateImage'],
    );
  }
}
