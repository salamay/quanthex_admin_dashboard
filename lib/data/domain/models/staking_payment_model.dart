class StakingPaymentModel {
  final String spId;
  final String spStakingId;
  final String spUid;
  final String spEmail;
  final String spStakingPlan;
  final double spAmount;
  final String? spTxData;
  final String? spTxHash;
  final int spChainId;
  final String? spRewardSymbol;
  final int spPaymentCycle;
  final int spReferralCountAtPayment;
  final String spStatus;
  final String spCreatedAt;
  final String spUpdatedAt;

  // Joined fields from stakings
  final String? stakingWalletAddress;
  final String? stakingRewardAssetSymbol;
  final String? stakingRewardAssetName;
  final int? stakingRewardChainId;
  final String? stakingRewardChainName;
  final String? stakingRewardContract;
  final double? stakedAmountFiat;
  final String? stakedAssetSymbol;

  StakingPaymentModel({
    required this.spId,
    required this.spStakingId,
    required this.spUid,
    required this.spEmail,
    required this.spStakingPlan,
    required this.spAmount,
    this.spTxData,
    this.spTxHash,
    required this.spChainId,
    this.spRewardSymbol,
    required this.spPaymentCycle,
    required this.spReferralCountAtPayment,
    required this.spStatus,
    required this.spCreatedAt,
    required this.spUpdatedAt,
    this.stakingWalletAddress,
    this.stakingRewardAssetSymbol,
    this.stakingRewardAssetName,
    this.stakingRewardChainId,
    this.stakingRewardChainName,
    this.stakingRewardContract,
    this.stakedAmountFiat,
    this.stakedAssetSymbol,
  });

  bool get isPending => spStatus.toLowerCase() == 'pending';
  bool get isConfirmed => spStatus.toLowerCase() == 'confirmed';

  String get cycleLabel => 'Cycle $spPaymentCycle';

  factory StakingPaymentModel.fromJson(Map<String, dynamic> json) {
    return StakingPaymentModel(
      spId: json['sp_id'] ?? '',
      spStakingId: json['sp_staking_id'] ?? '',
      spUid: json['sp_uid'] ?? '',
      spEmail: json['sp_email'] ?? '',
      spStakingPlan: json['sp_staking_plan'] ?? '',
      spAmount: (json['sp_amount'] ?? 0).toDouble(),
      spTxData: json['sp_tx_data'],
      spTxHash: json['sp_tx_hash'],
      spChainId: json['sp_chain_id'] ?? 0,
      spRewardSymbol: json['sp_reward_symbol'],
      spPaymentCycle: json['sp_payment_cycle'] ?? 0,
      spReferralCountAtPayment: json['sp_referral_count_at_payment'] ?? 0,
      spStatus: json['sp_status'] ?? 'pending',
      spCreatedAt: json['sp_created_at']?.toString() ?? '',
      spUpdatedAt: json['sp_updated_at']?.toString() ?? '',
      stakingWalletAddress: json['staking_wallet_address'],
      stakingRewardAssetSymbol: json['staking_reward_asset_symbol'],
      stakingRewardAssetName: json['staking_reward_asset_name'],
      stakingRewardChainId: json['staking_reward_chain_id'] != null
          ? int.tryParse(json['staking_reward_chain_id'].toString())
          : null,
      stakingRewardChainName: json['staking_reward_chain_name'],
      stakingRewardContract: json['staking_reward_contract'],
      stakedAmountFiat: json['staked_amount_fiat'] != null
          ? (json['staked_amount_fiat']).toDouble()
          : null,
      stakedAssetSymbol: json['staked_asset_symbol'],
    );
  }
}
