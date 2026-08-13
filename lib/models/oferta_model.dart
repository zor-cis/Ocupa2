int _aInt(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? 0;
}

double _aDouble(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0;
}

/// Tipo de trabajo del catálogo (GET /job-types).
class JobTypeModel {
  final String key;
  final String label;

  JobTypeModel({required this.key, required this.label});

  factory JobTypeModel.fromJson(Map<String, dynamic> json) {
    final key = (json['key'] ?? json['jobTypeKey'] ?? json['id'] ?? '').toString();
    return JobTypeModel(
      key: key,
      label: (json['label'] ?? json['name'] ?? json['nombre'] ?? key).toString(),
    );
  }
}

/// Oferta de empleo. Los campos siguen el schema real del API.
class OfertaModel {
  final String id;
  final String jobTypeKey;
  final String? jobTypeLabel;
  final String contractType; // temporal | fijo | horas
  final String description;
  final String? address;
  final String? photo;
  final double? lat;
  final double? lng;
  final double amount;
  final String currency;
  final DateTime? deadline;
  final String? status;
  final int totalApplications;
  final DateTime? createdAt;

  OfertaModel({
    required this.id,
    required this.jobTypeKey,
    this.jobTypeLabel,
    required this.contractType,
    required this.description,
    this.address,
    this.photo,
    this.lat,
    this.lng,
    required this.amount,
    this.currency = 'DOP',
    this.deadline,
    this.status,
    this.totalApplications = 0,
    this.createdAt,
  });

  factory OfertaModel.fromJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>?;
    final payment = json['payment'] as Map<String, dynamic>?;
    final jobType = json['jobType'] as Map<String, dynamic>?;

    return OfertaModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      jobTypeKey: (json['jobTypeKey'] ?? jobType?['key'] ?? '').toString(),
      jobTypeLabel: (jobType?['label'] ?? jobType?['name'])?.toString(),
      contractType: (json['contractType'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      address: json['address']?.toString(),
      photo: json['photo']?.toString(),
      lat: location?['lat'] == null ? null : _aDouble(location!['lat']),
      lng: location?['lng'] == null ? null : _aDouble(location!['lng']),
      amount: _aDouble(payment?['amount'] ?? json['amount']),
      currency: (payment?['currency'] ?? 'DOP').toString(),
      deadline: json['deadline'] == null
          ? null
          : DateTime.tryParse(json['deadline'].toString()),
      status: json['status']?.toString(),
      totalApplications: _aInt(
          json['applicationsCount'] ?? json['totalApplications'] ?? json['applications']),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.tryParse(json['createdAt'].toString()),
    );
  }

  bool get activa => status == null || status!.toLowerCase() == 'active';

  String get montoTexto =>
      currency == 'USD' ? 'US\$ ${amount.toStringAsFixed(0)}' : 'RD\$ ${amount.toStringAsFixed(0)}';

  String get tipoTexto => jobTypeLabel ?? jobTypeKey;

  String get estadoTexto => activa ? 'Activa' : 'Desactivada';
}

/// Aplicación de un candidato a una oferta.
class AplicacionModel {
  final String id;
  final String? userId;
  final String nombre;
  final String? foto;
  final String? comment;
  final bool esGanador;
  final DateTime? createdAt;

  AplicacionModel({
    required this.id,
    this.userId,
    required this.nombre,
    this.foto,
    this.comment,
    this.esGanador = false,
    this.createdAt,
  });

  factory AplicacionModel.fromJson(Map<String, dynamic> json) {
    final user = (json['user'] ?? json['applicant']) as Map<String, dynamic>?;

    final nombre = [
      user?['firstName'] ?? json['firstName'],
      user?['lastName'] ?? json['lastName'],
    ].where((e) => e != null && e.toString().isNotEmpty).join(' ');

    return AplicacionModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      userId: (user?['id'] ?? json['userId'])?.toString(),
      nombre: nombre.isEmpty
          ? (user?['email'] ?? json['email'] ?? 'Candidato').toString()
          : nombre,
      foto: (user?['photo'] ?? json['photo'])?.toString(),
      comment: json['comment']?.toString(),
      esGanador: json['isWinner'] == true || json['selected'] == true,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.tryParse(json['createdAt'].toString()),
    );
  }

  String get iniciales => nombre.trim().isEmpty ? '?' : nombre.trim()[0].toUpperCase();
}

/// Pago de la pasarela simulada.
class PagoModel {
  final String id;
  final double amount;
  final String currency;
  final String? status;
  final String? last4;
  final DateTime? createdAt;

  PagoModel({
    required this.id,
    required this.amount,
    this.currency = 'USD',
    this.status,
    this.last4,
    this.createdAt,
  });

  factory PagoModel.fromJson(Map<String, dynamic> json) {
    return PagoModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      amount: _aDouble(json['amount']),
      currency: (json['currency'] ?? 'USD').toString(),
      status: json['status']?.toString(),
      last4: (json['last4'] ?? json['cardLast4'])?.toString(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.tryParse(json['createdAt'].toString()),
    );
  }

  bool get aprobado => status == null || status!.toLowerCase().contains('approv');

  String get montoTexto => 'US\$ ${amount.toStringAsFixed(2)}';
}