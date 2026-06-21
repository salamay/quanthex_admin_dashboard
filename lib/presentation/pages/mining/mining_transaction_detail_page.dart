import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:quanthex_admin/core/theme/app_colors.dart';
import 'package:quanthex_admin/data/domain/models/mining_payment_model.dart';
import 'package:quanthex_admin/presentation/pages/mining/components/mining_info_row.dart';

class MiningTransactionDetailPage extends StatelessWidget {
  final MiningPaymentModel payment;

  const MiningTransactionDetailPage({super.key, required this.payment});

  String _formatDate(String? timestamp) {
    if (timestamp == null || timestamp.isEmpty) return 'N/A';
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
          'Transaction Detail',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: AppColors.textPrimary,
          ),
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
            _buildAmountBanner(),

            const SizedBox(height: 16),

            // Transaction Info
            _buildSection(
              title: 'Transaction Info',
              children: [
                MiningInfoRow(
                  label: 'ID',
                  value: _truncateAddress(payment.mpId),
                ),
                const SizedBox(height: 8),
                MiningInfoRow(
                  label: 'Status',
                  value: _capitalizeStatus(payment.mpStatus),
                ),
                const SizedBox(height: 8),
                MiningInfoRow(
                  label: 'Payment Number',
                  value: payment.tierLabel,
                ),
                const SizedBox(height: 8),
                MiningInfoRow(
                  label: 'Referrals at Payment',
                  value: '${payment.mpReferralCountAtPayment}',
                ),
                const SizedBox(height: 8),
                MiningInfoRow(
                  label: 'Chain ID',
                  value: '${payment.mpChainId}',
                ),
                const SizedBox(height: 8),
                MiningInfoRow(
                  label: 'Reward Symbol',
                  value: payment.mpRewardSymbol ??
                      payment.subRewardAssetSymbol ??
                      'N/A',
                ),
              ],
            ),

            const SizedBox(height: 16),

            // User Info
            _buildSection(
              title: 'User Info',
              children: [
                MiningInfoRow(
                  label: 'Email',
                  value: payment.userEmail ?? 'N/A',
                ),
                const SizedBox(height: 8),
                MiningInfoRow(
                  label: 'Mining ID',
                  value: _truncateAddress(payment.mpMinId),
                ),
                const SizedBox(height: 8),
                MiningInfoRow(
                  label: 'Wallet Address',
                  value: _truncateAddress(payment.miningWalletAddress),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Package Info
            _buildSection(
              title: 'Package Info',
              children: [
                MiningInfoRow(
                  label: 'Package Name',
                  value: payment.subPackageName ?? 'N/A',
                ),
                const SizedBox(height: 8),
                MiningInfoRow(
                  label: 'Asset Symbol',
                  value: payment.subAssetSymbol ?? 'N/A',
                ),
                const SizedBox(height: 8),
                MiningInfoRow(
                  label: 'Package Price',
                  value: payment.subPrice != null
                      ? '\$${payment.subPrice!.toStringAsFixed(2)}'
                      : 'N/A',
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Blockchain
            _buildSection(
              title: 'Blockchain',
              children: [
                if (payment.isConfirmed &&
                    payment.mpTxHash != null &&
                    payment.mpTxHash!.isNotEmpty) ...[
                  MiningInfoRow(
                    label: 'TX Hash',
                    value: _truncateAddress(payment.mpTxHash),
                  ),
                  const SizedBox(height: 8),
                ],
                MiningInfoRow(
                  label: 'Created',
                  value: _formatDate(payment.mpCreatedAt),
                ),
                const SizedBox(height: 8),
                MiningInfoRow(
                  label: 'Updated',
                  value: _formatDate(payment.mpUpdatedAt),
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountBanner() {
    Color statusBgColor;
    Color statusTextColor;
    String statusLabel;

    if (payment.isPending) {
      statusBgColor = AppColors.statusPendingBackground;
      statusTextColor = AppColors.statusPending;
      statusLabel = 'Pending';
    } else if (payment.isConfirmed) {
      statusBgColor = AppColors.statusActiveBackground;
      statusTextColor = AppColors.statusActive;
      statusLabel = 'Confirmed';
    } else {
      statusBgColor = AppColors.statusInactiveBackground;
      statusTextColor = AppColors.error;
      statusLabel = 'Failed';
    }

    return Container(
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
            'Mining Payment Amount',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${payment.mpAmount} ${payment.mpRewardSymbol}',
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
              color: statusBgColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: statusTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
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

  String _capitalizeStatus(String status) {
    if (status.isEmpty) return status;
    return status[0].toUpperCase() + status.substring(1).toLowerCase();
  }
}
