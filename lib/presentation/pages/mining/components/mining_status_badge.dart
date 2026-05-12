import 'package:flutter/material.dart';
import 'package:quanthex_admin/core/theme/app_colors.dart';

class MiningStatusBadge extends StatelessWidget {
  final String status;

  const MiningStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final isActive = status.toLowerCase() == 'active';
    final isPending = status.toLowerCase() == 'pending';

    Color backgroundColor;
    Color textColor;

    if (isActive) {
      backgroundColor = AppColors.statusActiveBackground;
      textColor = AppColors.statusActive;
    } else if (isPending) {
      backgroundColor = AppColors.statusPendingBackground;
      textColor = AppColors.statusPending;
    } else {
      backgroundColor = AppColors.statusInactiveBackground;
      textColor = AppColors.statusInactive;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
