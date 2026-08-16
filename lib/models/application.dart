import 'offer.dart';

class Application {
  final String id;
  final Offer offer;
  final String status;
  final String comment;
  final DateTime createdAt;

  Application({
    required this.id,
    required this.offer,
    required this.status,
    required this.comment,
    required this.createdAt,
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: json['id']?.toString() ?? '',
      offer: Offer.fromJson(json['offer'] ?? {}),
      status: json['status'] ?? 'applied',
      comment: json['comment'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
