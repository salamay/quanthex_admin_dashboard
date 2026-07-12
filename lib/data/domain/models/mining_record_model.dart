import 'earning_model.dart';
import 'mining_info_model.dart';
import 'payment_status_model.dart';
import 'subscription_model.dart';

class MiningRecordModel {
  final MiningInfoModel? mining;
  final SubscriptionModel? subscription;
  final String? referralCode;
  final String? referrerEmail;
  final int directReferralCount;
  final int indirectReferralCount;
  final EarningModel earnings;
  final PaymentStatusModel paymentStatus;

  MiningRecordModel({
    this.mining,
    this.subscription,
    this.referralCode,
    this.referrerEmail,
    this.directReferralCount = 0,
    this.indirectReferralCount = 0,
    required this.earnings,
    PaymentStatusModel? paymentStatus,
  }) : paymentStatus = paymentStatus ?? PaymentStatusModel.empty();

  int get totalReferralCount => directReferralCount + indirectReferralCount;

  /// Eligibility is now driven by backend payment tier logic.
  bool get isEligibleForPayment => paymentStatus.isEligibleForPayment;

  factory MiningRecordModel.fromJson(Map<String, dynamic> json) {
    return MiningRecordModel(
      mining: json['mining'] != null
          ? MiningInfoModel.fromJson(json['mining'] as Map<String, dynamic>)
          : null,
      subscription: json['subscription'] != null
          ? SubscriptionModel.fromJson(json['subscription'] as Map<String, dynamic>)
          : null,
      referralCode: json['referral_code']?.toString(),
      referrerEmail: json['referrer_email']?.toString(),
      directReferralCount: (json['direct_referral_count'] as num?)?.toInt() ?? 0,
      indirectReferralCount: (json['indirect_referral_count'] as num?)?.toInt() ?? 0,
      earnings: json['earnings'] != null
          ? EarningModel.fromJson(json['earnings'] as Map<String, dynamic>)
          : EarningModel.empty(),
      paymentStatus: PaymentStatusModel.fromJson(
          json['payment_status'] is Map<String, dynamic> ? json['payment_status'] : null),
    );
  }
}
