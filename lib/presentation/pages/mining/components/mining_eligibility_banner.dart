import 'package:flutter/material.dart';
import 'package:quanthex_admin/core/theme/app_colors.dart';
import 'package:quanthex_admin/data/domain/models/mining_record_model.dart';

class MiningEligibilityBanner extends StatelessWidget {
  final MiningRecordModel record;

  const MiningEligibilityBanner({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final isEligible = record.isEligibleForPayment;
    final allPaid = record.paymentStatus.allTiersPaid;
    final paidTiers = record.paymentStatus.paidTiers;
    final nextRequired = record.paymentStatus.nextRequiredTier ?? 6;

    final Color bannerColor = allPaid
        ? AppColors.primary
        : isEligible
            ? AppColors.statusActive
            : AppColors.statusPending;

    final Color bannerBg = allPaid
        ? AppColors.primarySurface
        : isEligible
            ? AppColors.statusActiveBackground
            : AppColors.statusPendingBackground;

    String title;
    String subtitle;
    IconData icon;

    if (allPaid) {
      title = 'Fully Paid';
      subtitle = 'All 4 payment tiers completed';
      icon = Icons.verified;
    } else if (isEligible) {
      title = 'Eligible for Payment (Tier ${record.paymentStatus.nextTier})';
      subtitle = '${record.directReferralCount} direct referrals — ${paidTiers.length}/4 tiers paid';
      icon = Icons.check_circle_rounded;
    } else {
      title = 'Not Eligible for Payment';
      subtitle = '${record.directReferralCount} of $nextRequired direct referrals needed for next tier';
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
          if (paidTiers.isNotEmpty || !allPaid) ...[
            const SizedBox(height: 12),
            Row(
              children: [6, 36, 216, 1296].map((tier) {
                final isPaid = paidTiers.contains(tier);
                final isNext = tier == record.paymentStatus.nextTier;
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: isPaid
                          ? AppColors.statusActive.withValues(alpha: 0.15)
                          : isNext
                              ? AppColors.primary.withValues(alpha: 0.1)
                              : AppColors.border.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: isNext
                          ? Border.all(color: AppColors.primary.withValues(alpha: 0.4))
                          : null,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          isPaid ? Icons.check_circle : Icons.radio_button_unchecked,
                          size: 16,
                          color: isPaid
                              ? AppColors.statusActive
                              : isNext
                                  ? AppColors.primary
                                  : AppColors.textTertiary,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$tier',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isPaid || isNext ? FontWeight.w600 : FontWeight.w400,
                            color: isPaid
                                ? AppColors.statusActive
                                : isNext
                                    ? AppColors.primary
                                    : AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
