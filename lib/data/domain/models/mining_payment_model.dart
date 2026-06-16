class MiningPaymentModel {
  final String mpId;
  final String mpMinId;
  final String mpUid;
  final String mpSubscriptionId;
  final String? mpTxHash;
  final String? mpTxData;
  final double mpAmount;
  final int mpChainId;
  final String? mpRewardSymbol;
  final int mpPaymentTier;
  final int mpReferralCountAtPayment;
  final String mpStatus;
  final String mpCreatedAt;
  final String mpUpdatedAt;

  // Joined fields from minings + subscriptions
  final String? userEmail;
  final String? miningWalletAddress;
  final String? miningTag;
  final String? subPackageName;
  final String? subRewardAssetSymbol;
  final String? subRewardAssetName;
  final int? subRewardChainId;
  final String? subRewardContract;
  final String? subAssetSymbol;
  final double? subPrice;

  MiningPaymentModel({
    required this.mpId,
    required this.mpMinId,
    required this.mpUid,
    required this.mpSubscriptionId,
    this.mpTxHash,
    this.mpTxData,
    required this.mpAmount,
    required this.mpChainId,
    this.mpRewardSymbol,
    required this.mpPaymentTier,
    required this.mpReferralCountAtPayment,
    required this.mpStatus,
    required this.mpCreatedAt,
    required this.mpUpdatedAt,
    this.userEmail,
    this.miningWalletAddress,
    this.miningTag,
    this.subPackageName,
    this.subRewardAssetSymbol,
    this.subRewardAssetName,
    this.subRewardChainId,
    this.subRewardContract,
    this.subAssetSymbol,
    this.subPrice,
  });

  bool get isPending => mpStatus.toLowerCase() == 'pending';
  bool get isConfirmed => mpStatus.toLowerCase() == 'confirmed';
  bool get isFailed => mpStatus.toLowerCase() == 'failed';

  String get tierLabel => 'Payment #$mpPaymentTier';

  factory MiningPaymentModel.fromJson(Map<String, dynamic> json) {
    return MiningPaymentModel(
      mpId: json['mp_id'] ?? '',
      mpMinId: json['mp_min_id'] ?? '',
      mpUid: json['mp_uid'] ?? '',
      mpSubscriptionId: json['mp_subscription_id'] ?? '',
      mpTxHash: json['mp_tx_hash'],
      mpTxData: json['mp_tx_data'],
      mpAmount: (json['mp_amount'] is num) ? (json['mp_amount'] as num).toDouble() : double.tryParse(json['mp_amount']?.toString() ?? '0') ?? 0,
      mpChainId: json['mp_chain_id'] ?? 0,
      mpRewardSymbol: json['mp_reward_symbol'],
      mpPaymentTier: json['mp_payment_tier'] ?? 0,
      mpReferralCountAtPayment: json['mp_referral_count_at_payment'] ?? 0,
      mpStatus: json['mp_status'] ?? 'pending',
      mpCreatedAt: json['mp_created_at']?.toString() ?? '',
      mpUpdatedAt: json['mp_updated_at']?.toString() ?? '',
      userEmail: json['user_email'],
      miningWalletAddress: json['mining_wallet_address'],
      miningTag: json['mining_tag'],
      subPackageName: json['sub_package_name'],
      subRewardAssetSymbol: json['sub_reward_asset_symbol'],
      subRewardAssetName: json['sub_reward_asset_name'],
      subRewardChainId: json['sub_reward_chain_id'] != null
          ? int.tryParse(json['sub_reward_chain_id'].toString())
          : null,
      subRewardContract: json['sub_reward_contract'],
      subAssetSymbol: json['sub_asset_symbol'],
      subPrice: json['sub_price'] != null
          ? double.parse((json['sub_price']).toString())
          : 0,
    );
  }
}
