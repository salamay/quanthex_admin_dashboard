import 'package:flutter/material.dart';
import 'package:quanthex_admin/core/theme/app_colors.dart';
import 'package:quanthex_admin/data/domain/models/staking_record_model.dart';

class StakingEligibilityBanner extends StatelessWidget {
  final StakingRecordModel record;
  const StakingEligibilityBanner({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final ps = record.paymentStatus;
    final Color bgColor;
    final Color textColor;
    final IconData icon;
    final String message;

    if (ps.isExpired) {
      bgColor = AppColors.error.withOpacity(0.1);
      textColor = AppColors.error;
      icon = Icons.cancel_outlined;
      message = 'Staking duration has expired. No further payments eligible.';
    } else if (ps.isEligibleForPayment) {
      bgColor = AppColors.statusActiveBackground;
      textColor = AppColors.statusActive;
      icon = Icons.check_circle_outline;
      message = 'Eligible for payment of \$${ps.doublePaymentAmount.toStringAsFixed(2)} at ${ps.rewardPercentage.toStringAsFixed(0)}% (Cycle ${ps.nextCycle})';
    } else {
      bgColor = AppColors.statusPendingBackground;
      textColor = AppColors.statusPending;
      icon = Icons.info_outline;
      final needed = ps.nextCycle * 6;
      final remaining = needed - record.referralCount;
      message = 'Needs $remaining more referrals ($needed total) for next payment cycle.';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: textColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
