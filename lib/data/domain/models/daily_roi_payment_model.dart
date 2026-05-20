class DailyRoiPaymentModel {
  final String drpId;
  final String stakingId;
  final String uid;
  final String email;
  final String stakingPlan;
  final double stakedAmount;
  final double roiPercentage;
  final double payoutAmount;
  final String paymentDate;
  final int chainId;
  final String rewardSymbol;
  final String walletAddress;
  final String? txData;
  final String? txHash;
  final String status;
  final String createdAt;
  final String updatedAt;

  DailyRoiPaymentModel({
    required this.drpId,
    required this.stakingId,
    required this.uid,
    required this.email,
    required this.stakingPlan,
    required this.stakedAmount,
    required this.roiPercentage,
    required this.payoutAmount,
    required this.paymentDate,
    required this.chainId,
    required this.rewardSymbol,
    required this.walletAddress,
    this.txData,
    this.txHash,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isConfirmed => status.toLowerCase() == 'confirmed';

  factory DailyRoiPaymentModel.fromJson(Map<String, dynamic> json) {
    return DailyRoiPaymentModel(
      drpId: json['drp_id'] ?? '',
      stakingId: json['drp_staking_id'] ?? '',
      uid: json['drp_uid'] ?? '',
      email: json['drp_email'] ?? '',
      stakingPlan: json['drp_staking_plan'] ?? '',
      stakedAmount: (json['drp_staked_amount'] ?? 0).toDouble(),
      roiPercentage: (json['drp_roi_percentage'] ?? 0).toDouble(),
      payoutAmount: (json['drp_payout_amount'] ?? 0).toDouble(),
      paymentDate: json['drp_payment_date']?.toString() ?? '',
      chainId: json['drp_chain_id'] ?? 0,
      rewardSymbol: json['drp_reward_symbol'] ?? '',
      walletAddress: json['drp_wallet_address'] ?? '',
      txData: json['drp_tx_data'],
      txHash: json['drp_tx_hash'],
      status: json['drp_status'] ?? 'pending',
      createdAt: json['drp_created_at']?.toString() ?? '',
      updatedAt: json['drp_updated_at']?.toString() ?? '',
    );
  }
}
