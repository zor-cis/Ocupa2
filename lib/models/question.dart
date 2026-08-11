class Question {
  final String id;
  final String label;
  final String type;
  final bool required;
  final List<String> options;

  Question({
    required this.id,
    required this.label,
    required this.type,
    required this.required,
    required this.options,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      label: json['label'],
      type: json['type'],
      required: json['required'],
      options: json['options'] != null
          ? List<String>.from(json['options'])
          : [],
    );
  }
}