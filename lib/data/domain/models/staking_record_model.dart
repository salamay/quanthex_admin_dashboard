import 'staking_info_model.dart';
import 'staking_payment_status_model.dart';

class StakingRecordModel {
  final StakingInfoModel? staking;
  final int referralCount;
  final StakingPaymentStatusModel paymentStatus;

  StakingRecordModel({
    this.staking,
    this.referralCount = 0,
    required this.paymentStatus,
  });

  bool get isEligibleForPayment => paymentStatus.isEligibleForPayment;

  factory StakingRecordModel.fromJson(Map<String, dynamic> json) {
    return StakingRecordModel(
      staking: json['staking'] != null
          ? StakingInfoModel.fromJson(json['staking'] as Map<String, dynamic>)
          : null,
      referralCount: (json['referral_count'] as num?)?.toInt() ?? 0,
      paymentStatus: StakingPaymentStatusModel.fromJson(
        json['payment_status'] is Map<String, dynamic>
            ? json['payment_status']
            : null,
      ),
    );
  }
}
