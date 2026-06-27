class UserSubscriptionModel {
  final String subId;
  final String uid;
  final String? email;
  final String? subType;
  final int? subChainId;
  final String? subAssetContract;
  final String? subAssetSymbol;
  final String? subAssetName;
  final int? subAssetDecimals;
  final String? subAssetImage;
  final String? subCreatedAt;
  final String? subUpdatedAt;
  final String? subStatus;
  final String? subRewardContract;
  final int? subRewardChainId;
  final String? subRewardAssetName;
  final String? subRewardAssetSymbol;
  final String? subRewardAssetImage;
  final int? subRewardAssetDecimals;
  final String? subPackageName;
  final String? subDuration;
  final double? subPrice;
  final String? subReferralCode;
  final String? subMiningTag;
  final String? subWalletHash;
  final String? subWalletAddress;

  UserSubscriptionModel({
    required this.subId,
    required this.uid,
    this.email,
    this.subType,
    this.subChainId,
    this.subAssetContract,
    this.subAssetSymbol,
    this.subAssetName,
    this.subAssetDecimals,
    this.subAssetImage,
    this.subCreatedAt,
    this.subUpdatedAt,
    this.subStatus,
    this.subRewardContract,
    this.subRewardChainId,
    this.subRewardAssetName,
    this.subRewardAssetSymbol,
    this.subRewardAssetImage,
    this.subRewardAssetDecimals,
    this.subPackageName,
    this.subDuration,
    this.subPrice,
    this.subReferralCode,
    this.subMiningTag,
    this.subWalletHash,
    this.subWalletAddress,
  });

  factory UserSubscriptionModel.fromJson(Map<String, dynamic> json) {
    return UserSubscriptionModel(
      subId: json['sub_id']?.toString() ?? '',
      uid: json['uid']?.toString() ?? '',
      email: json['email']?.toString(),
      subType: json['sub_type']?.toString(),
      subChainId: json['sub_chain_id'] != null ? int.tryParse(json['sub_chain_id'].toString()) : null,
      subAssetContract: json['sub_asset_contract']?.toString(),
      subAssetSymbol: json['sub_asset_symbol']?.toString(),
      subAssetName: json['sub_asset_name']?.toString(),
      subAssetDecimals: json['sub_asset_decimals'] != null ? int.tryParse(json['sub_asset_decimals'].toString()) : null,
      subAssetImage: json['sub_asset_image']?.toString(),
      subCreatedAt: json['sub_created_at']?.toString(),
      subUpdatedAt: json['sub_updated_at']?.toString(),
      subStatus: json['sub_status']?.toString(),
      subRewardContract: json['sub_reward_contract']?.toString(),
      subRewardChainId: json['sub_reward_chain_id'] != null ? int.tryParse(json['sub_reward_chain_id'].toString()) : null,
      subRewardAssetName: json['sub_reward_asset_name']?.toString(),
      subRewardAssetSymbol: json['sub_reward_asset_symbol']?.toString(),
      subRewardAssetImage: json['sub_reward_asset_image']?.toString(),
      subRewardAssetDecimals: json['sub_reward_asset_decimals'] != null ? int.tryParse(json['sub_reward_asset_decimals'].toString()) : null,
      subPackageName: json['sub_package_name']?.toString(),
      subDuration: json['sub_duration']?.toString(),
      subPrice: json['sub_price'] != null ? double.tryParse(json['sub_price'].toString()) : null,
      subReferralCode: json['sub_referral_code']?.toString(),
      subMiningTag: json['sub_mining_tag']?.toString(),
      subWalletHash: json['sub_wallet_hash']?.toString(),
      subWalletAddress: json['sub_wallet_address']?.toString(),
    );
  }

  bool get isActive => subStatus?.toLowerCase() == 'active';

  String get displayDuration {
    if (subDuration == null) return 'N/A';
    final millis = int.tryParse(subDuration!);
    if (millis == null) return 'N/A';
    final days = millis ~/ (1000 * 60 * 60 * 24);
    if (days >= 365) {
      final years = days ~/ 365;
      return '$years year${years > 1 ? 's' : ''}';
    } else if (days >= 30) {
      final months = days ~/ 30;
      return '$months month${months > 1 ? 's' : ''}';
    }
    return '$days day${days > 1 ? 's' : ''}';
  }
}
