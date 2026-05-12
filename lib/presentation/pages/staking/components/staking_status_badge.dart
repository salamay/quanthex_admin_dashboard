import 'package:flutter/material.dart';
import 'package:quanthex_admin/core/theme/app_colors.dart';

class StakingStatusBadge extends StatelessWidget {
  final String status;
  const StakingStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final isActive = status.toLowerCase() == 'active';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isActive ? AppColors.statusActiveBackground : AppColors.statusPendingBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isActive ? AppColors.statusActive : AppColors.statusPending,
        ),
      ),
    );
  }
}
