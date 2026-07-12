class MiningReferralModel {
  final String referralId;
  final String referralUid;
  final String referreeUid;
  final String? referralSubscriptionId;
  final String? referreeSubscriptionId;
  final String? referralCreatedAt;
  final int? depth;
  final String? referreeEmail;
  final String? referreeReferralCode;

  MiningReferralModel({
    required this.referralId,
    required this.referralUid,
    required this.referreeUid,
    this.referralSubscriptionId,
    this.referreeSubscriptionId,
    this.referralCreatedAt,
    this.depth,
    this.referreeEmail,
    this.referreeReferralCode,
  });

  /// Parses from ReferralDto shape: { info: ReferralEntity, profile: ProfileEntity }
  factory MiningReferralModel.fromJson(Map<String, dynamic> json) {
    final info = json['info'] as Map<String, dynamic>? ?? {};
    final profile = json['profile'] as Map<String, dynamic>? ?? {};

    return MiningReferralModel(
      referralId: info['referral_id']?.toString() ?? '',
      referralUid: info['referral_uid']?.toString() ?? '',
      referreeUid: info['referree_uid']?.toString() ?? '',
      referralSubscriptionId: info['referral_subscription_id']?.toString(),
      referreeSubscriptionId: info['referree_subscription_id']?.toString(),
      referralCreatedAt: info['referral_created_at']?.toString(),
      depth: info['depth'] is num ? (info['depth'] as num).toInt() : null,
      referreeEmail: profile['email']?.toString(),
      referreeReferralCode: profile['referral_code']?.toString(),
    );
  }
}
