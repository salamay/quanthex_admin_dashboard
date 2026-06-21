import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:quanthex_admin/core/router/app_router.dart';
import 'package:quanthex_admin/core/theme/app_colors.dart';
import 'package:quanthex_admin/data/domain/models/upline_payment_model.dart';
import 'package:quanthex_admin/presentation/providers/asset_controllers.dart';
import 'package:quanthex_admin/presentation/providers/upline_payments_provider.dart';
import 'package:quanthex_admin/presentation/pages/mining/components/mining_info_row.dart';
import 'package:intl/intl.dart';

class UplinePaymentDetailPage extends StatelessWidget {
  final UplinePaymentModel payment;
  const UplinePaymentDetailPage({super.key, required this.payment});

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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Upline Payment Detail',
          style: TextStyle(
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
            // Amount banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  const Text(
                    'Upline Payment Amount',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${payment.amount} ${payment.rewardSymbol}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: payment.isPending
                          ? Colors.orange.withOpacity(0.15)
                          : Colors.green.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      payment.isPending ? 'Pending' : 'Paid',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: payment.isPending ? Colors.orange : Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Upline info
            _buildSection(
              title: 'Upline (Referrer)',
              children: [
                MiningInfoRow(label: 'Email', value: payment.uplineEmail),
                const SizedBox(height: 8),
                MiningInfoRow(label: 'UID', value: payment.uplineUid),
                const SizedBox(height: 8),
                MiningInfoRow(label: 'Staking ID', value: _truncateAddress(payment.uplineStakingId)),
                const SizedBox(height: 8),
                MiningInfoRow(label: 'Wallet', value: _truncateAddress(payment.uplineWalletAddress)),
              ],
            ),

            const SizedBox(height: 16),

            // Downline info
            _buildSection(
              title: 'Downline (Referree)',
              children: [
                MiningInfoRow(label: 'UID', value: payment.downlineUid),
                const SizedBox(height: 8),
                MiningInfoRow(label: 'Staking ID', value: _truncateAddress(payment.downlineStakingId)),
                const SizedBox(height: 8),
                MiningInfoRow(label: 'Plan', value: payment.downlineStakingPlan),
              ],
            ),

            const SizedBox(height: 16),

            // Payment details
            _buildSection(
              title: 'Payment Details',
              children: [
                MiningInfoRow(label: 'Reward Symbol', value: payment.uplineRewardAssetSymbol ?? payment.rewardSymbol ?? 'N/A'),
                const SizedBox(height: 8),
                MiningInfoRow(label: 'Reward Chain', value: payment.uplineRewardChainName ?? 'N/A'),
                const SizedBox(height: 8),
                MiningInfoRow(label: 'Created', value: _formatDate(payment.createdAt)),
                const SizedBox(height: 8),
                if (payment.isConfirmed) ...[
                  MiningInfoRow(label: 'TX Hash', value: _truncateAddress(payment.txHash)),
                  const SizedBox(height: 8),
                  MiningInfoRow(label: 'Paid At', value: _formatDate(payment.updatedAt)),
                ],
              ],
            ),

            const SizedBox(height: 24),

            // Pay button (only for pending)
            if (payment.isPending)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    final rwdSymbol = payment.uplineRewardAssetSymbol ?? payment.rewardSymbol ?? '';
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
                        'uplinePayment': payment,
                      },
                    );

                    if (result != null && context.mounted) {
                      context.read<UplinePaymentsProvider>().fetchPayments(refresh: true);
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
                    'Pay \$${payment.amount.toStringAsFixed(2)} to Upline',
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
