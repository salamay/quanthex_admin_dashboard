class StakingSettingsModel {
  final String ssId;
  final String planName;
  final double planAmount;
  final double rewardPercentage; // 100 = full double, 50 = half
  final int referralsPerCycle;
  final bool isActive;

  StakingSettingsModel({
    required this.ssId,
    required this.planName,
    required this.planAmount,
    required this.rewardPercentage,
    required this.referralsPerCycle,
    required this.isActive,
  });

  /// Computed double payment: plan_amount * 2 * (percentage / 100)
  double get computedDoublePayment => planAmount * 2 * (rewardPercentage / 100);

  factory StakingSettingsModel.fromJson(Map<String, dynamic> json) {
    return StakingSettingsModel(
      ssId: json['ss_id']?.toString() ?? '',
      planName: json['ss_plan_name']?.toString() ?? '',
      planAmount: (json['ss_plan_amount'] as num?)?.toDouble() ?? 0,
      rewardPercentage: (json['ss_reward_percentage'] as num?)?.toDouble() ?? 100,
      referralsPerCycle: (json['ss_referrals_per_cycle'] as num?)?.toInt() ?? 6,
      isActive: json['ss_is_active'] == 1 || json['ss_is_active'] == true,
    );
  }
}
