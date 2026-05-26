class PaymentStatusModel {
  final int totalPayments;
  final int nextPaymentNumber;
  final bool isEligibleForPayment;

  PaymentStatusModel({
    this.totalPayments = 0,
    this.nextPaymentNumber = 1,
    this.isEligibleForPayment = false,
  });

  factory PaymentStatusModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return PaymentStatusModel.empty();
    final rawTotal = json['total_payments'];
    final rawNext = json['next_payment_number'];
    return PaymentStatusModel(
      totalPayments: rawTotal is num ? rawTotal.toInt() : 0,
      nextPaymentNumber: rawNext is num ? rawNext.toInt() : 1,
      isEligibleForPayment: json['is_eligible_for_payment'] == true,
    );
  }

  factory PaymentStatusModel.empty() {
    return PaymentStatusModel();
  }
}
