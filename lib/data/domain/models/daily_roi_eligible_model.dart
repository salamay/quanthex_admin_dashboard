class DailyRoiEligibleModel {
  final String stakingId;
  final String uid;
  final String email;
  final String stakingPlan;
  final double stakedAmountFiat;
  final String stakingWalletAddress;
  final String stakingRewardAssetSymbol;
  final int stakingRewardChainId;
  final double payoutAmount;
  final String? status;

  DailyRoiEligibleModel({
    required this.stakingId,
    required this.uid,
    required this.email,
    required this.stakingPlan,
    required this.stakedAmountFiat,
    required this.stakingWalletAddress,
    required this.stakingRewardAssetSymbol,
    required this.stakingRewardChainId,
    required this.payoutAmount,
    this.status,
  });

  factory DailyRoiEligibleModel.fromJson(Map<String, dynamic> json) {
    return DailyRoiEligibleModel(
      stakingId: json['staking_id'] ?? '',
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      stakingPlan: json['staking_plan'] ?? '',
      stakedAmountFiat: (json['staked_amount_fiat'] ?? 0).toDouble(),
      stakingWalletAddress: json['staking_wallet_address'] ?? '',
      stakingRewardAssetSymbol: json['staking_reward_asset_symbol'] ?? '',
      stakingRewardChainId: json['staking_reward_chain_id'] ?? 0,
      payoutAmount: (json['payout_amount'] ?? 0).toDouble(),
      status: json['status'],
    );
  }
}
