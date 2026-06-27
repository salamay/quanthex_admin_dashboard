class PaymentStatusModel {
  final int totalPayments;
  final int nextPaymentNumber;
  final bool isEligibleForPayment;
  final double totalAmountPaid;

  PaymentStatusModel({
    this.totalPayments = 0,
    this.nextPaymentNumber = 1,
    this.isEligibleForPayment = false,
    this.totalAmountPaid = 0,
  });

  factory PaymentStatusModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return PaymentStatusModel.empty();
    final rawTotal = json['total_payments'];
    final rawNext = json['next_payment_number'];
    final rawAmountPaid = json['total_amount_paid'];
    return PaymentStatusModel(
      totalPayments: rawTotal is num ? rawTotal.toInt() : 0,
      nextPaymentNumber: rawNext is num ? rawNext.toInt() : 1,
      isEligibleForPayment: json['is_eligible_for_payment'] == true,
      totalAmountPaid: rawAmountPaid is num ? rawAmountPaid.toDouble() : 0,
    );
  }

  factory PaymentStatusModel.empty() {
    return PaymentStatusModel();
  }
}
