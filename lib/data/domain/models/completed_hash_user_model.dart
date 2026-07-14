class CompletedHashUserModel {
  final String uid;
  final String email;
  final String accountStatus;
  final String roles;
  final String? userCreatedAt;
  final String? regVia;
  final String? referralCode;
  final String? profileCreatedAt;
  final String? profileUpdatedAt;
  final String? packageName;
  final int directReferralCount;

  CompletedHashUserModel({
    required this.uid,
    required this.email,
    required this.accountStatus,
    required this.roles,
    this.userCreatedAt,
    this.regVia,
    this.referralCode,
    this.profileCreatedAt,
    this.profileUpdatedAt,
    this.packageName,
    this.directReferralCount = 0,
  });

  factory CompletedHashUserModel.fromJson(Map<String, dynamic> json) {
    return CompletedHashUserModel(
      uid: json['uid']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      accountStatus: json['account_status']?.toString() ?? 'unknown',
      roles: json['roles']?.toString() ?? '',
      userCreatedAt: json['user_created_at']?.toString(),
      regVia: json['reg_via']?.toString(),
      referralCode: json['referral_code']?.toString(),
      profileCreatedAt: json['profile_created_at']?.toString(),
      profileUpdatedAt: json['profile_updated_at']?.toString(),
      packageName: json['sub_package_name']?.toString(),
      directReferralCount: (json['direct_referral_count'] as num?)?.toInt() ?? 0,
    );
  }

  bool get isActive => accountStatus.toLowerCase() == 'active';
}
