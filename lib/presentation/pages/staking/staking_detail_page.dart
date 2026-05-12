import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:quanthex_admin/core/router/app_router.dart';
import 'package:quanthex_admin/core/theme/app_colors.dart';
import 'package:quanthex_admin/data/domain/models/staking_record_model.dart';
import 'package:quanthex_admin/presentation/providers/asset_controllers.dart';
import 'package:quanthex_admin/presentation/providers/staking_provider.dart';
import 'package:quanthex_admin/presentation/pages/mining/components/mining_info_row.dart';
import 'package:intl/intl.dart';
import 'components/staking_eligibility_banner.dart';

class StakingDetailPage extends StatelessWidget {
  final StakingRecordModel record;
  const StakingDetailPage({super.key, required this.record});

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

  @override
  Widget build(BuildContext context) {
    final staking = record.staking;
    final ps = record.paymentStatus;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: false,
        title: Text(
          staking?.stakingPlan ?? 'Staking Detail',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info card
            _buildSection(
              title: 'User Info',
              children: [
                MiningInfoRow(label: 'Email', value: staking?.email ?? 'N/A'),
                const SizedBox(height: 8),
                MiningInfoRow(label: 'UID', value: staking?.uid ?? 'N/A'),
                const SizedBox(height: 8),
                MiningInfoRow(label: 'Referral Code', value: staking?.stakingReferralCode ?? 'N/A'),
              ],
            ),

            const SizedBox(height: 16),

            // Staking info
            _buildSection(
              title: 'Staking Details',
              children: [
                MiningInfoRow(label: 'Plan', value: staking?.stakingPlan ?? 'N/A'),
                const SizedBox(height: 8),
                MiningInfoRow(label: 'Status', value: staking?.stakingStatus ?? 'N/A'),
                const SizedBox(height: 8),
                MiningInfoRow(label: 'Amount (Fiat)', value: '\$${staking?.stakedAmountFiat ?? '0'}'),
                const SizedBox(height: 8),
                MiningInfoRow(label: 'Amount (Crypto)', value: '${staking?.stakedAmountCrypto ?? '0'} ${staking?.stakedAssetSymbol ?? ''}'),
                const SizedBox(height: 8),
                MiningInfoRow(label: 'Asset', value: staking?.stakedAssetName ?? 'N/A'),
                const SizedBox(height: 8),
                MiningInfoRow(label: 'Wallet', value: _truncateAddress(staking?.stakingWalletAddress)),
                const SizedBox(height: 8),
                MiningInfoRow(label: 'Start Date', value: _formatDate(staking?.startDate)),
                const SizedBox(height: 8),
                MiningInfoRow(label: 'End Date', value: _formatDate(staking?.endDate)),
                const SizedBox(height: 8),
                MiningInfoRow(label: 'Created', value: _formatDate(staking?.stakeCreatedAt)),
              ],
            ),

            const SizedBox(height: 16),

            // Reward info
            _buildSection(
              title: 'Reward Info',
              children: [
                MiningInfoRow(label: 'Reward Asset', value: staking?.stakingRewardAssetName ?? 'N/A'),
                const SizedBox(height: 8),
                MiningInfoRow(label: 'Reward Symbol', value: staking?.stakingRewardAssetSymbol ?? 'N/A'),
                const SizedBox(height: 8),
                MiningInfoRow(label: 'Reward Chain', value: staking?.stakingRewardChainName ?? 'N/A'),
              ],
            ),

            const SizedBox(height: 16),

            // Referral & Payment status
            _buildSection(
              title: 'Payment Status',
              children: [
                MiningInfoRow(label: 'Referral Count', value: '${record.referralCount}'),
                const SizedBox(height: 8),
                MiningInfoRow(label: 'Completed Cycles', value: '${ps.completedReferralCycles}'),
                const SizedBox(height: 8),
                MiningInfoRow(label: 'Paid Cycles', value: ps.paidCycles.isNotEmpty ? ps.paidCycles.join(', ') : 'None'),
                const SizedBox(height: 8),
                MiningInfoRow(label: 'Next Cycle', value: '${ps.nextCycle}'),
                const SizedBox(height: 8),
                MiningInfoRow(label: 'Reward %', value: '${ps.rewardPercentage.toStringAsFixed(0)}%'),
                const SizedBox(height: 8),
                MiningInfoRow(label: 'Current Payout', value: '\$${ps.doublePaymentAmount.toStringAsFixed(2)}'),
                const SizedBox(height: 8),
                MiningInfoRow(label: 'Expired', value: ps.isExpired ? 'Yes' : 'No'),
                const SizedBox(height: 12),

                // Eligibility banner
                StakingEligibilityBanner(record: record),
              ],
            ),

            const SizedBox(height: 24),

            // Pay button
            if (record.isEligibleForPayment)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    final rwdSymbol = staking?.stakingRewardAssetSymbol ?? '';
                    final assetCtr = context.read<AssetController>();
                    final matchingCoin = assetCtr.assets.where(
                      (c) => c.symbol.toLowerCase() == rwdSymbol.toLowerCase(),
                    ).firstOrNull;

                    if (matchingCoin == null) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Reward asset "$rwdSymbol" not found in your wallet assets'),
                            backgroundColor: AppColors.error,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                      return;
                    }

                    final result = await context.push<String>(
                      AppRoutes.sendToken,
                      extra: {
                        'coin': matchingCoin,
                        'stakingRecord': record,
                      },
                    );

                    if (result != null && context.mounted) {
                      context.read<StakingProvider>().fetchStakings(refresh: true);
                      if (context.mounted) context.pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Pay \$${ps.doublePaymentAmount.toStringAsFixed(2)} (${ps.rewardPercentage.toStringAsFixed(0)}%) - Cycle ${ps.nextCycle}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

}
