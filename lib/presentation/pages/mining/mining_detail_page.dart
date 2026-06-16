import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quanthex_admin/core/router/app_router.dart';
import 'package:quanthex_admin/core/theme/app_colors.dart';
import 'package:quanthex_admin/presentation/providers/asset_controllers.dart';
import 'package:quanthex_admin/presentation/providers/balance_controller.dart';
import 'package:quanthex_admin/presentation/providers/mining_provider.dart';
import 'package:quanthex_admin/data/domain/models/mining_record_model.dart';
import 'components/header_card.dart';
import 'components/mining_eligibility_banner.dart';
import 'components/earnings_card.dart';
import 'components/referral_stats_card.dart';
import 'components/section_card.dart';
import 'components/detail_row.dart';

class MiningDetailPage extends StatelessWidget {
  final MiningRecordModel record;

  const MiningDetailPage({super.key, required this.record});

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
    if (address == null || address.length < 16) return address ?? 'N/A';
    return '${address.substring(0, 8)}...${address.substring(address.length - 8)}';
  }

  void _copyToClipboard(BuildContext context, String? text) {
    if (text == null || text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Copied to clipboard'),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _getPayButtonText(MiningRecordModel record, double totalEarning, String rewardSymbol) {
    if (record.isEligibleForPayment) {
      return 'Pay ${totalEarning.toStringAsFixed(2)} $rewardSymbol (Payment #${record.paymentStatus.nextPaymentNumber})';
    }
    return 'Not Eligible (need 1 more referral)';
  }

  @override
  Widget build(BuildContext context) {
    final mining = record.mining;
    final subscription = record.subscription;
    final earnings = record.earnings;
    final rewardSymbol = subscription?.subRewardAssetSymbol ?? '';

    // Convert USDT earnings to DOGE using market price
    final dogePrice = context.read<BalanceController>().priceQuotes['DOGE'];
    final canConvert = dogePrice != null && dogePrice > 0;
    final displayDirect = canConvert ? earnings.directEarning / dogePrice : earnings.directEarning;
    final displayIndirect = canConvert ? earnings.indirectEarning / dogePrice : earnings.indirectEarning;
    final displayTotal = canConvert ? earnings.totalEarning / dogePrice : earnings.totalEarning;
    final displaySymbol = canConvert ? 'DOGE' : rewardSymbol;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          subscription?.subPackageName ?? 'Mining Detail',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
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
            HeaderCard(
              packageName: subscription?.subPackageName ?? 'Unknown',
              status: subscription?.subStatus ?? 'Unknown',
              email: mining?.email ?? 'N/A',
              referralCode: record.referralCode ?? 'N/A',
            ),
            const SizedBox(height: 16),

            MiningEligibilityBanner(record: record),
            const SizedBox(height: 12),

            // View Payments button
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                onPressed: () {
                  context.push(AppRoutes.miningPayments, extra: record);
                },
                icon: const Icon(Icons.receipt_long_outlined, size: 18),
                label: Text(
                  'View Payment History (${record.paymentStatus.totalPayments})',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary, width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            EarningsCard(
              directEarning: displayDirect,
              indirectEarning: displayIndirect,
              totalEarning: displayTotal,
              rewardSymbol: displaySymbol,
            ),
            const SizedBox(height: 16),

            ReferralStatsCard(
              directCount: record.directReferralCount,
              indirectCount: record.indirectReferralCount,
              totalCount: record.totalReferralCount,
            ),
            const SizedBox(height: 16),

            SectionCard(
              title: 'Subscription Details',
              icon: Icons.receipt_long_outlined,
              children: [
                DetailRow(label: 'Subscription ID', value: subscription?.subId ?? 'N/A', copyable: true, onCopy: () => _copyToClipboard(context, subscription?.subId)),
                DetailRow(label: 'Type', value: subscription?.subType ?? 'N/A'),
                DetailRow(label: 'Duration', value: subscription?.subDuration ?? 'N/A'),
                DetailRow(label: 'Price', value: subscription?.subPrice != null ? '\$${subscription!.subPrice!.toStringAsFixed(2)}' : 'N/A'),
                DetailRow(label: 'Created', value: _formatDate(subscription?.subCreatedAt)),
                DetailRow(label: 'Updated', value: _formatDate(subscription?.subUpdatedAt)),
                DetailRow(label: 'Referral Code', value: subscription?.subReferralCode ?? 'N/A'),
              ],
            ),
            const SizedBox(height: 16),

            SectionCard(
              title: 'Asset Information',
              icon: Icons.token_outlined,
              children: [
                DetailRow(label: 'Asset Name', value: subscription?.subAssetName ?? 'N/A'),
                DetailRow(label: 'Asset Symbol', value: subscription?.subAssetSymbol ?? 'N/A'),
                DetailRow(label: 'Chain ID', value: subscription?.subChainId?.toString() ?? 'N/A'),
                DetailRow(label: 'Contract', value: _truncateAddress(subscription?.subAssetContract), copyable: true, onCopy: () => _copyToClipboard(context, subscription?.subAssetContract)),
                DetailRow(label: 'Decimals', value: subscription?.subAssetDecimals?.toString() ?? 'N/A'),
              ],
            ),
            const SizedBox(height: 16),

            SectionCard(
              title: 'Reward Information',
              icon: Icons.emoji_events_outlined,
              children: [
                DetailRow(label: 'Reward Asset', value: subscription?.subRewardAssetName ?? 'N/A'),
                DetailRow(label: 'Reward Symbol', value: rewardSymbol.isNotEmpty ? rewardSymbol : 'N/A'),
                DetailRow(label: 'Reward Chain ID', value: subscription?.subRewardChainId?.toString() ?? 'N/A'),
                DetailRow(label: 'Reward Contract', value: _truncateAddress(subscription?.subRewardContract), copyable: true, onCopy: () => _copyToClipboard(context, subscription?.subRewardContract)),
                DetailRow(label: 'Reward Decimals', value: subscription?.subRewardAssetDecimals?.toString() ?? 'N/A'),
              ],
            ),
            const SizedBox(height: 16),

            SectionCard(
              title: 'Mining Information',
              icon: Icons.memory_outlined,
              children: [
                DetailRow(label: 'Mining ID', value: mining?.minId ?? 'N/A', copyable: true, onCopy: () => _copyToClipboard(context, mining?.minId)),
                DetailRow(label: 'User ID', value: mining?.uid ?? 'N/A', copyable: true, onCopy: () => _copyToClipboard(context, mining?.uid)),
                DetailRow(label: 'Mining Tag', value: mining?.miningTag ?? 'N/A'),
                DetailRow(label: 'Wallet Address', value: _truncateAddress(mining?.miningWalletAddress), copyable: true, onCopy: () => _copyToClipboard(context, mining?.miningWalletAddress)),
                DetailRow(label: 'Wallet Hash', value: _truncateAddress(mining?.miningWalletHash), copyable: true, onCopy: () => _copyToClipboard(context, mining?.miningWalletHash)),
                DetailRow(label: 'Created', value: _formatDate(mining?.minCreatedAt)),
                DetailRow(label: 'Updated', value: _formatDate(mining?.minUpdatedAt)),
              ],
            ),
            const SizedBox(height: 24),

            // Pay button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: record.isEligibleForPayment
                    ? () async {
                        final sub = record.subscription;
                        final assetController = context.read<AssetController>();
                        final rwdSymbol = sub?.subRewardAssetSymbol ?? '';
                        final coins = assetController.assets.where(
                          (coin) => coin.symbol.toLowerCase() == rwdSymbol.toLowerCase(),
                        );
                        final matchingCoin = coins.isNotEmpty ? coins.first : null;

                        if (matchingCoin == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Reward asset "$rwdSymbol" not found in your wallet assets'),
                              backgroundColor: AppColors.error,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }

                        final result = await context.push(AppRoutes.sendToken, extra: {
                          'coin': matchingCoin,
                          'miningRecord': record,
                        });

                        if (result != null && context.mounted) {
                          context.read<MiningProvider>().fetchMinings(refresh: true);
                          if (context.mounted) context.pop();
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.border,
                  disabledForegroundColor: AppColors.textTertiary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.payment, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      _getPayButtonText(record, displayTotal, displaySymbol),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Manual Pay button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: () async {
                  final sub = record.subscription;
                  final assetController = context.read<AssetController>();
                  final rwdSymbol = sub?.subRewardAssetSymbol ?? '';
                  final coins = assetController.assets.where(
                    (coin) => coin.symbol.toLowerCase() == rwdSymbol.toLowerCase(),
                  );
                  final matchingCoin = coins.isNotEmpty ? coins.first : null;

                  if (matchingCoin == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Reward asset "$rwdSymbol" not found in your wallet assets'),
                        backgroundColor: AppColors.error,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }

                  final result = await context.push(AppRoutes.sendToken, extra: {
                    'coin': matchingCoin,
                    'miningRecord': record,
                    'isManualMiningPayment': true,
                  });

                  if (result != null && context.mounted) {
                    context.read<MiningProvider>().fetchMinings(refresh: true);
                    if (context.mounted) context.pop();
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.send_outlined, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Manual Pay (Any Amount)',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
