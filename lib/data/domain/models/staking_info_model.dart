class StakingInfoModel {
  final String? stakingId;
  final String? uid;
  final String? email;
  final String? stakeCreatedAt;
  final String? stakeUpdatedAt;
  final String? stakedAssetSymbol;
  final String? stakedAssetContract;
  final String? stakedAssetName;
  final String? stakedAssetImage;
  final String? stakedAmountFiat;
  final String? stakedAmountCrypto;
  final String? stakingStatus;
  final String? stakingRewardContract;
  final int? stakingRewardChainId;
  final String? stakingRewardChainName;
  final String? stakingRewardAssetName;
  final String? stakingRewardAssetSymbol;
  final int? stakingRewardAssetDecimals;
  final String? stakingRewardAssetImage;
  final String? duration;
  final String? endDate;
  final String? startDate;
  final String? stakingWalletHash;
  final String? stakingWalletAddress;
  final String? stakingReferralCode;
  final String? stakingPlan;

  StakingInfoModel({
    this.stakingId,
    this.uid,
    this.email,
    this.stakeCreatedAt,
    this.stakeUpdatedAt,
    this.stakedAssetSymbol,
    this.stakedAssetContract,
    this.stakedAssetName,
    this.stakedAssetImage,
    this.stakedAmountFiat,
    this.stakedAmountCrypto,
    this.stakingStatus,
    this.stakingRewardContract,
    this.stakingRewardChainId,
    this.stakingRewardChainName,
    this.stakingRewardAssetName,
    this.stakingRewardAssetSymbol,
    this.stakingRewardAssetDecimals,
    this.stakingRewardAssetImage,
    this.duration,
    this.endDate,
    this.startDate,
    this.stakingWalletHash,
    this.stakingWalletAddress,
    this.stakingReferralCode,
    this.stakingPlan,
  });

  factory StakingInfoModel.fromJson(Map<String, dynamic> json) {
    return StakingInfoModel(
      stakingId: json['staking_id']?.toString(),
      uid: json['uid']?.toString(),
      email: json['email']?.toString(),
      stakeCreatedAt: json['stake_created_at']?.toString(),
      stakeUpdatedAt: json['stake_updated_at']?.toString(),
      stakedAssetSymbol: json['staked_asset_symbol']?.toString(),
      stakedAssetContract: json['staked_asset_contract']?.toString(),
      stakedAssetName: json['staked_asset_name']?.toString(),
      stakedAssetImage: json['staked_asset_image']?.toString(),
      stakedAmountFiat: json['staked_amount_fiat']?.toString(),
      stakedAmountCrypto: json['staked_amount_crypto']?.toString(),
      stakingStatus: json['staking_status']?.toString(),
      stakingRewardContract: json['staking_reward_contract']?.toString(),
      stakingRewardChainId: (json['staking_reward_chain_id'] as num?)?.toInt(),
      stakingRewardChainName: json['staking_reward_chain_name']?.toString(),
      stakingRewardAssetName: json['staking_reward_asset_name']?.toString(),
      stakingRewardAssetSymbol: json['staking_reward_asset_symbol']?.toString(),
      stakingRewardAssetDecimals: (json['staking_reward_asset_decimals'] as num?)?.toInt(),
      stakingRewardAssetImage: json['staking_reward_asset_image']?.toString(),
      duration: json['duration']?.toString(),
      endDate: json['end_date']?.toString(),
      startDate: json['start_date']?.toString(),
      stakingWalletHash: json['staking_wallet_hash']?.toString(),
      stakingWalletAddress: json['staking_wallet_address']?.toString(),
      stakingReferralCode: json['staking_referral_code']?.toString(),
      stakingPlan: json['staking_plan']?.toString(),
    );
  }
}
