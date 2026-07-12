import 'package:flutter/material.dart';
import 'package:quanthex_admin/core/theme/app_colors.dart';

class ReferralStatsCard extends StatelessWidget {
  final int directCount;
  final int indirectCount;
  final int totalCount;
  final VoidCallback? onTap;

  const ReferralStatsCard({
    super.key,
    required this.directCount,
    required this.indirectCount,
    required this.totalCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.group_outlined, size: 18, color: AppColors.primary),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Referrals',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                if (onTap != null)
                  const Icon(Icons.chevron_right_rounded, size: 22, color: AppColors.textTertiary),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: StatTile(label: 'Direct', count: directCount, color: AppColors.success)),
                const SizedBox(width: 10),
                Expanded(child: StatTile(label: 'Indirect', count: indirectCount, color: AppColors.info)),
                const SizedBox(width: 10),
                Expanded(child: StatTile(label: 'Total', count: totalCount, color: AppColors.primary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class StatTile extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const StatTile({
    super.key,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
