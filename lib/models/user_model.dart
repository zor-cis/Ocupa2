class UserModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? cedula;
  final String? gender;
  final DateTime? birthDate;
  final bool profileCompleted;

  UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.cedula,
    this.gender,
    this.birthDate,
    this.profileCompleted = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      cedula: json['cedula'],
      gender: json['gender'],
      birthDate: json['birthDate'] != null
          ? DateTime.tryParse(json['birthDate'].toString())
          : null,
      profileCompleted: json['profileCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'cedula': cedula,
      'gender': gender,
      'birthDate': birthDate?.toIso8601String(),
      'profileCompleted': profileCompleted,
    };
  }
}