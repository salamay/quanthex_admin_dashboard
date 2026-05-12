class UplinePaymentModel {
  final String supId;
  final String stakingPaymentId;
  final String uplineUid;
  final String uplineEmail;
  final String uplineStakingId;
  final String downlineUid;
  final String downlineStakingId;
  final String downlineStakingPlan;
  final double amount;
  final String? txData;
  final String? txHash;
  final int chainId;
  final String? rewardSymbol;
  final String status; // pending | confirmed
  final String createdAt;
  final String updatedAt;

  // Joined fields from upline's staking record
  final String? uplineWalletAddress;
  final int? uplineRewardChainId;
  final String? uplineRewardAssetSymbol;
  final String? uplineRewardAssetName;
  final String? uplineRewardChainName;
  final int? uplineRewardAssetDecimals;
  final String? uplineRewardContract;
  final String? uplineRewardAssetImage;

  UplinePaymentModel({
    required this.supId,
    required this.stakingPaymentId,
    required this.uplineUid,
    required this.uplineEmail,
    required this.uplineStakingId,
    required this.downlineUid,
    required this.downlineStakingId,
    required this.downlineStakingPlan,
    required this.amount,
    this.txData,
    this.txHash,
    required this.chainId,
    this.rewardSymbol,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.uplineWalletAddress,
    this.uplineRewardChainId,
    this.uplineRewardAssetSymbol,
    this.uplineRewardAssetName,
    this.uplineRewardChainName,
    this.uplineRewardAssetDecimals,
    this.uplineRewardContract,
    this.uplineRewardAssetImage,
  });

  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';

  factory UplinePaymentModel.fromJson(Map<String, dynamic> json) {
    return UplinePaymentModel(
      supId: json['sup_id']?.toString() ?? '',
      stakingPaymentId: json['sup_staking_payment_id']?.toString() ?? '',
      uplineUid: json['sup_upline_uid']?.toString() ?? '',
      uplineEmail: json['sup_upline_email']?.toString() ?? '',
      uplineStakingId: json['sup_upline_staking_id']?.toString() ?? '',
      downlineUid: json['sup_downline_uid']?.toString() ?? '',
      downlineStakingId: json['sup_downline_staking_id']?.toString() ?? '',
      downlineStakingPlan: json['sup_downline_staking_plan']?.toString() ?? '',
      amount: (json['sup_amount'] as num?)?.toDouble() ?? 0.0,
      txData: json['sup_tx_data']?.toString(),
      txHash: json['sup_tx_hash']?.toString(),
      chainId: (json['sup_chain_id'] as num?)?.toInt() ?? 0,
      rewardSymbol: json['sup_reward_symbol']?.toString(),
      status: json['sup_status']?.toString() ?? 'pending',
      createdAt: json['sup_created_at']?.toString() ?? '',
      updatedAt: json['sup_updated_at']?.toString() ?? '',
      uplineWalletAddress: json['upline_wallet_address']?.toString(),
      uplineRewardChainId: (json['upline_reward_chain_id'] as num?)?.toInt(),
      uplineRewardAssetSymbol: json['upline_reward_asset_symbol']?.toString(),
      uplineRewardAssetName: json['upline_reward_asset_name']?.toString(),
      uplineRewardChainName: json['upline_reward_chain_name']?.toString(),
      uplineRewardAssetDecimals: (json['upline_reward_asset_decimals'] as num?)?.toInt(),
      uplineRewardContract: json['upline_reward_contract']?.toString(),
      uplineRewardAssetImage: json['upline_reward_asset_image']?.toString(),
    );
  }
}
