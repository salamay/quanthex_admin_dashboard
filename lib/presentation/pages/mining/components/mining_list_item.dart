import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quanthex_admin/core/router/app_router.dart';
import 'package:quanthex_admin/core/theme/app_colors.dart';
import 'mining_status_badge.dart';
import 'mining_info_row.dart';
import 'package:intl/intl.dart';

import '../../../../data/domain/models/mining_record_model.dart';

class MiningListItem extends StatelessWidget {
  final MiningRecordModel record;
  final int index;

  const MiningListItem({
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
      return DateFormat('MMM dd, yyyy • hh:mm a').format(date);
    } catch (_) {
      return 'N/A';
    }
  }

  String _truncateAddress(String? address) {
    if (address == null || address.length < 12) return address ?? 'N/A';
    return '${address.substring(0, 6)}...${address.substring(address.length - 6)}';
  }

  String _getEligibilityText(MiningRecordModel record) {
    if (record.paymentStatus.allTiersPaid) return 'Fully Paid';
    if (record.isEligibleForPayment) {
      return 'Eligible (Tier ${record.paymentStatus.nextTier})';
    }
    final nextRequired = record.paymentStatus.nextRequiredTier ?? 6;
    return 'Not Eligible (${record.directReferralCount}/$nextRequired referrals)';
  }

  @override
  Widget build(BuildContext context) {
    final mining = record.mining;
    final subscription = record.subscription;

    return GestureDetector(
      onTap: () {
        context.push(AppRoutes.miningDetail, extra: record);
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Padding(
          padding: EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: package name + status
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
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              subscription?.subPackageName ?? 'Unknown Package',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 2),
                            Text(
                              mining?.email ?? 'N/A',
                              style: TextStyle(
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
                MiningStatusBadge(status: subscription?.subStatus ?? 'Unknown'),
              ],
            ),

            SizedBox(height: 12),
            Divider(color: AppColors.divider, height: 1),
            SizedBox(height: 12),

            // Info rows
            MiningInfoRow(
              label: 'Mining Tag',
              value: mining?.miningTag ?? 'N/A',
            ),
            SizedBox(height: 8),
            MiningInfoRow(
              label: 'Wallet Address',
              value: _truncateAddress(mining?.miningWalletAddress),
            ),
            SizedBox(height: 8),
            MiningInfoRow(
              label: 'Price',
              value: subscription?.subPrice != null
                  ? '\$${subscription!.subPrice!.toStringAsFixed(2)}'
                  : 'N/A',
            ),
            SizedBox(height: 8),
            MiningInfoRow(
              label: 'Asset',
              value: subscription?.subAssetSymbol ?? 'N/A',
            ),
            SizedBox(height: 8),
            MiningInfoRow(
              label: 'Reward',
              value: subscription?.subRewardAssetSymbol ?? 'N/A',
            ),
            SizedBox(height: 8),
            MiningInfoRow(
              label: 'Created',
              value: _formatDate(mining?.minCreatedAt),
            ),

            // Earnings section
            SizedBox(height: 12),
            Divider(color: AppColors.divider, height: 1),
            SizedBox(height: 12),
            _EarningsSection(
              directEarning: record.earnings.directEarning,
              indirectEarning: record.earnings.indirectEarning,
              totalEarning: record.earnings.totalEarning,
              rewardSymbol: subscription?.subRewardAssetSymbol ?? '',
            ),

            // Eligibility tag
            SizedBox(height: 10),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: record.isEligibleForPayment
                        ? AppColors.statusActiveBackground
                        : record.paymentStatus.allTiersPaid
                            ? AppColors.primarySurface
                            : AppColors.statusPendingBackground,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        record.isEligibleForPayment
                            ? Icons.check_circle_outline
                            : record.paymentStatus.allTiersPaid
                                ? Icons.verified
                                : Icons.info_outline,
                        size: 14,
                        color: record.isEligibleForPayment
                            ? AppColors.statusActive
                            : record.paymentStatus.allTiersPaid
                                ? AppColors.primary
                                : AppColors.statusPending,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getEligibilityText(record),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: record.isEligibleForPayment
                              ? AppColors.statusActive
                              : record.paymentStatus.allTiersPaid
                                  ? AppColors.primary
                                  : AppColors.statusPending,
                        ),
                      ),
                    ],
                  ),
                ),
                if (record.paymentStatus.paidTiers.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Paid: ${record.paymentStatus.paidTiers.length}/4 tiers',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
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

class _EarningsSection extends StatelessWidget {
  final double directEarning;
  final double indirectEarning;
  final double totalEarning;
  final String rewardSymbol;

  const _EarningsSection({
    required this.directEarning,
    required this.indirectEarning,
    required this.totalEarning,
    required this.rewardSymbol,
  });

  @override
  Widget build(BuildContext context) {
    final symbol = rewardSymbol.isNotEmpty ? ' $rewardSymbol' : '';
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Amount Earned',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _EarningItem(
                  label: 'Direct',
                  value: '${directEarning.toStringAsFixed(2)}$symbol',
                ),
              ),
              Expanded(
                child: _EarningItem(
                  label: 'Indirect',
                  value: '${indirectEarning.toStringAsFixed(2)}$symbol',
                ),
              ),
              Expanded(
                child: _EarningItem(
                  label: 'Total',
                  value: '${totalEarning.toStringAsFixed(2)}$symbol',
                  isBold: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EarningItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _EarningItem({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: isBold ? AppColors.primary : AppColors.textPrimary,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
