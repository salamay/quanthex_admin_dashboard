import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quanthex_admin/core/router/app_router.dart';
import 'package:quanthex_admin/core/theme/app_colors.dart';
import 'package:quanthex_admin/presentation/pages/mining/components/mining_info_row.dart';
import 'staking_status_badge.dart';
import 'package:intl/intl.dart';

import '../../../../data/domain/models/staking_record_model.dart';

class StakingListItem extends StatelessWidget {
  final StakingRecordModel record;
  final int index;

  const StakingListItem({
    super.key,
    required this.record,
    required this.index,
  });

  String _formatDate(String? timestamp) {
    if (timestamp == null) return 'N/A';
    try {
      final millis = int.tryParse(timestamp);
      if (millis == null) return 'N/A';
      final date = DateTime.fromMillisecondsSinceEpoch(millis);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (_) {
      return 'N/A';
    }
  }

  String _truncateAddress(String? address) {
    if (address == null || address.length < 12) return address ?? 'N/A';
    return '${address.substring(0, 6)}...${address.substring(address.length - 6)}';
  }

  String _getEligibilityText() {
    final ps = record.paymentStatus;
    if (ps.isExpired) return 'Expired';
    if (ps.isEligibleForPayment) return 'Eligible (Cycle ${ps.nextCycle})';
    return 'Not Eligible (${record.referralCount}/${ps.nextCycle * 6} referrals)';
  }

  Color _getEligibilityColor() {
    final ps = record.paymentStatus;
    if (ps.isExpired) return AppColors.error;
    if (ps.isEligibleForPayment) return AppColors.statusActive;
    return AppColors.statusPending;
  }

  Color _getEligibilityBgColor() {
    final ps = record.paymentStatus;
    if (ps.isExpired) return AppColors.error.withOpacity(0.1);
    if (ps.isEligibleForPayment) return AppColors.statusActiveBackground;
    return AppColors.statusPendingBackground;
  }

  @override
  Widget build(BuildContext context) {
    final staking = record.staking;

    return GestureDetector(
      onTap: () {
        context.push(AppRoutes.stakingDetail, extra: record);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                staking?.stakingPlan ?? 'Unknown Plan',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                staking?.email ?? 'N/A',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.textSecondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  StakingStatusBadge(status: staking?.stakingStatus ?? 'Unknown'),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(color: AppColors.divider, height: 1),
              const SizedBox(height: 12),

              // Info rows
              MiningInfoRow(
                label: 'Staked Amount',
                value: '\$${staking?.stakedAmountFiat ?? '0'}',
              ),
              const SizedBox(height: 8),
              MiningInfoRow(
                label: 'Asset',
                value: staking?.stakedAssetSymbol ?? 'N/A',
              ),
              const SizedBox(height: 8),
              MiningInfoRow(
                label: 'Reward Asset',
                value: staking?.stakingRewardAssetSymbol ?? 'N/A',
              ),
              const SizedBox(height: 8),
              MiningInfoRow(
                label: 'Wallet',
                value: _truncateAddress(staking?.stakingWalletAddress),
              ),
              const SizedBox(height: 8),
              MiningInfoRow(
                label: 'Referrals',
                value: '${record.referralCount}',
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: MiningInfoRow(
                      label: 'Start',
                      value: _formatDate(staking?.startDate),
                    ),
                  ),
                  Expanded(
                    child: MiningInfoRow(
                      label: 'End',
                      value: _formatDate(staking?.endDate),
                    ),
                  ),
                ],
              ),

              // Payment info
              const SizedBox(height: 12),
              const Divider(color: AppColors.divider, height: 1),
              const SizedBox(height: 10),

              Row(
                children: [
                  // Eligibility tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _getEligibilityBgColor(),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          record.paymentStatus.isEligibleForPayment
                              ? Icons.check_circle_outline
                              : record.paymentStatus.isExpired
                                  ? Icons.cancel_outlined
                                  : Icons.info_outline,
                          size: 14,
                          color: _getEligibilityColor(),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getEligibilityText(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _getEligibilityColor(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (record.paymentStatus.paidCycles.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Paid: ${record.paymentStatus.paidCycles.length} cycles',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                  if (record.paymentStatus.doublePaymentAmount > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.statusActiveBackground,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '\$${record.paymentStatus.doublePaymentAmount.toStringAsFixed(2)} (${record.paymentStatus.rewardPercentage.toStringAsFixed(0)}%)',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.statusActive,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

