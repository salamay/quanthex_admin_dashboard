class MiningInfoModel {
  final String? minId;
  final String? uid;
  final String? email;
  final String? minCreatedAt;
  final String? minUpdatedAt;
  final String? minSubscriptionId;
  final String? miningTag;
  final String? miningWalletHash;
  final String? miningWalletAddress;

  MiningInfoModel({
    this.minId,
    this.uid,
    this.email,
    this.minCreatedAt,
    this.minUpdatedAt,
    this.minSubscriptionId,
    this.miningTag,
    this.miningWalletHash,
    this.miningWalletAddress,
  });

  factory MiningInfoModel.fromJson(Map<String, dynamic> json) {
    return MiningInfoModel(
      minId: json['min_id']?.toString(),
      uid: json['uid']?.toString(),
      email: json['email']?.toString(),
      minCreatedAt: json['min_created_at']?.toString(),
      minUpdatedAt: json['min_updated_at']?.toString(),
      minSubscriptionId: json['min_subscription_id']?.toString(),
      miningTag: json['mining_tag']?.toString(),
      miningWalletHash: json['mining_wallet_hash']?.toString(),
      miningWalletAddress: json['mining_wallet_address']?.toString(),
    );
  }
}
