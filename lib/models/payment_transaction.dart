class PaymentTransaction {
  final String id;
  final double amount;
  final String currency;
  final String status;
  final DateTime createdAt;
  final String? type;
  final String? cardholder;
  final String? cardLast4;
  final String? declineReason;

  PaymentTransaction({
    required this.id,
    required this.amount,
    required this.currency,
    required this.status,
    required this.createdAt,
    this.type,
    this.cardholder,
    this.cardLast4,
    this.declineReason,
  });

  factory PaymentTransaction.fromJson(Map<String, dynamic> json) {
    return PaymentTransaction(
      id: json['id']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'USD',
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      type: json['concept'] ?? json['type'] ?? json['description'] ?? 'Pago de oferta',
      cardholder: json['cardholder'],
      cardLast4: json['cardLast4'],
      declineReason: json['declineReason'],
    );
  }
}
