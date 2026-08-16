class JobType {
  final String key;
  final String name;

  JobType({
    required this.key,
    required this.name,
  });

  factory JobType.fromJson(Map<String, dynamic> json) {
    return JobType(
      key: json['key'] ?? '',
      name: json['name'] ?? '',
    );
  }
}
