class Payment {
  final double amount;
  final String currency;
  final String period;

  Payment({
    required this.amount,
    required this.currency,
    required this.period,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'],
      period: json['period'],
    );
  }
}