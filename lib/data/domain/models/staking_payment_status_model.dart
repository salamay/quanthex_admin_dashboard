class StakingPaymentStatusModel {
  final List<int> paidCycles;
  final int nextCycle;
  final int completedReferralCycles;
  final bool isEligibleForPayment;
  final bool isExpired;
  final double rewardPercentage; // Current admin-set percentage (100 = full double)
  final double doublePaymentAmount; // Computed: plan_amount * 2 * (percentage / 100)

  StakingPaymentStatusModel({
    required this.paidCycles,
    required this.nextCycle,
    required this.completedReferralCycles,
    required this.isEligibleForPayment,
    required this.isExpired,
    required this.rewardPercentage,
    required this.doublePaymentAmount,
  });

  factory StakingPaymentStatusModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return StakingPaymentStatusModel.empty();

    final rawPaidCycles = json['paid_cycles'];
    final List<int> paidCycles = [];
    if (rawPaidCycles is List) {
      for (final item in rawPaidCycles) {
        if (item is num) paidCycles.add(item.toInt());
      }
    }

    return StakingPaymentStatusModel(
      paidCycles: paidCycles,
      nextCycle: (json['next_cycle'] is num) ? (json['next_cycle'] as num).toInt() : 1,
      completedReferralCycles: (json['completed_referral_cycles'] is num) ? (json['completed_referral_cycles'] as num).toInt() : 0,
      isEligibleForPayment: json['is_eligible_for_payment'] == true,
      isExpired: json['is_expired'] == true,
      rewardPercentage: (json['reward_percentage'] is num) ? (json['reward_percentage'] as num).toDouble() : 100.0,
      doublePaymentAmount: (json['double_payment_amount'] is num) ? (json['double_payment_amount'] as num).toDouble() : 0.0,
    );
  }

  factory StakingPaymentStatusModel.empty() {
    return StakingPaymentStatusModel(
      paidCycles: [],
      nextCycle: 1,
      completedReferralCycles: 0,
      isEligibleForPayment: false,
      isExpired: false,
      rewardPercentage: 100,
      doublePaymentAmount: 0,
    );
  }
}
