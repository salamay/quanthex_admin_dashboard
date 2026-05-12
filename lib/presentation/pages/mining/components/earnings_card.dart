import 'package:flutter/material.dart';
import 'package:quanthex_admin/core/theme/app_colors.dart';

class EarningsCard extends StatelessWidget {
  final double directEarning;
  final double indirectEarning;
  final double totalEarning;
  final String rewardSymbol;

  const EarningsCard({
    super.key,
    required this.directEarning,
    required this.indirectEarning,
    required this.totalEarning,
    required this.rewardSymbol,
  });

  @override
  Widget build(BuildContext context) {
    final symbol = rewardSymbol.isNotEmpty ? ' $rewardSymbol' : '';
    return Container(
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
                child: const Icon(Icons.account_balance_wallet_outlined, size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              const Text(
                'Amount Earned',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                Text(
                  '${totalEarning.toStringAsFixed(4)}$symbol',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Total Earned',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: EarningColumn(
                  label: 'Direct Earning',
                  value: '${directEarning.toStringAsFixed(4)}$symbol',
                  icon: Icons.person_outline,
                ),
              ),
              Container(width: 1, height: 40, color: AppColors.divider),
              Expanded(
                child: EarningColumn(
                  label: 'Indirect Earning',
                  value: '${indirectEarning.toStringAsFixed(4)}$symbol',
                  icon: Icons.people_outline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EarningColumn extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const EarningColumn({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
