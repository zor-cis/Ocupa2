import 'location.dart';
import 'payment.dart';
import 'question.dart';

class Offer {
  final String id;
  final String jobTypeKey;
  final String jobTypeName;
  final String contractType;
  final String description;
  final String address;
  final Location location;
  final Payment payment;
  final String photo;
  final DateTime? deadline;
  final dynamic customAnswers;
  final List<Question> questions;
  final String status;
  final int applicantsCount;
  final int likesCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isIdentityRevealed;
  final bool likedByMe;

  Offer({
    required this.id,
    required this.jobTypeKey,
    required this.jobTypeName,
    required this.contractType,
    required this.description,
    required this.address,
    required this.location,
    required this.payment,
    required this.photo,
    this.deadline,
    required this.customAnswers,
    required this.questions,
    required this.status,
    required this.applicantsCount,
    required this.likesCount,
    required this.createdAt,
    required this.updatedAt,
    required this.isIdentityRevealed,
    required this.likedByMe,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['id'],
      jobTypeKey: json['jobTypeKey'],
      jobTypeName: json['jobTypeName'],
      contractType: json['contractType'],
      description: json['description'],
      address: json['address'],
      location: Location.fromJson(json['location']),
      payment: Payment.fromJson(json['payment']),
      photo: json['photo'],
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'])
          : null,
      customAnswers: json['customAnswers'],
      questions: (json['questions'] as List)
          .map((question) => Question.fromJson(question))
          .toList(),
      status: json['status'],
      applicantsCount: json['applicantsCount'],
      likesCount: json['likesCount'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isIdentityRevealed: json['isIdentityRevealed'],
      likedByMe: json['likedByMe'],
    );
  }
}