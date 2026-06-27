class UserReferralModel {
  final String referralId;
  final String referralUid;
  final String referreeUid;
  final String? referralSubscriptionId;
  final String? referreeSubscriptionId;
  final String? referralCreatedAt;
  final int? depth;
  final String? referreeEmail;
  final String? referreeReferralCode;
  final String? subPackageName;

  UserReferralModel({
    required this.referralId,
    required this.referralUid,
    required this.referreeUid,
    this.referralSubscriptionId,
    this.referreeSubscriptionId,
    this.referralCreatedAt,
    this.depth,
    this.referreeEmail,
    this.referreeReferralCode,
    this.subPackageName,
  });

  factory UserReferralModel.fromJson(Map<String, dynamic> json) {
    return UserReferralModel(
      referralId: json['referral_id']?.toString() ?? '',
      referralUid: json['referral_uid']?.toString() ?? '',
      referreeUid: json['referree_uid']?.toString() ?? '',
      referralSubscriptionId: json['referral_subscription_id']?.toString(),
      referreeSubscriptionId: json['referree_subscription_id']?.toString(),
      referralCreatedAt: json['referral_created_at']?.toString(),
      depth: json['depth'] is num ? (json['depth'] as num).toInt() : null,
      referreeEmail: json['referree_email']?.toString(),
      referreeReferralCode: json['referree_referral_code']?.toString(),
      subPackageName: json['sub_package_name']?.toString(),
    );
  }
}
