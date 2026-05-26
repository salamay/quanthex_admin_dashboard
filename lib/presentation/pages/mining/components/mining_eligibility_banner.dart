import 'package:flutter/material.dart';
import 'package:quanthex_admin/core/theme/app_colors.dart';
import 'package:quanthex_admin/data/domain/models/mining_record_model.dart';

class MiningEligibilityBanner extends StatelessWidget {
  final MiningRecordModel record;

  const MiningEligibilityBanner({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final isEligible = record.isEligibleForPayment;
    final totalPayments = record.paymentStatus.totalPayments;
    final nextPaymentNumber = record.paymentStatus.nextPaymentNumber;
    final referralCount = record.directReferralCount;

    final Color bannerColor = isEligible
        ? AppColors.statusActive
        : AppColors.statusPending;

    final Color bannerBg = isEligible
        ? AppColors.statusActiveBackground
        : AppColors.statusPendingBackground;

    String title;
    String subtitle;
    IconData icon;

    if (isEligible) {
      title = 'Eligible for Payment #$nextPaymentNumber';
      subtitle = '$referralCount referrals — $totalPayments payments made';
      icon = Icons.check_circle_rounded;
    } else {
      title = 'Not Eligible for Payment';
      subtitle = '$referralCount referrals — needs 1 more referral for payment #$nextPaymentNumber';
      icon = Icons.warning_amber_rounded;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: bannerBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bannerColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 22, color: bannerColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: bannerColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: bannerColor.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Referral vs Payment count indicators
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$referralCount',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Referrals',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.statusActiveBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$totalPayments',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.statusActive,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Payments Made',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
