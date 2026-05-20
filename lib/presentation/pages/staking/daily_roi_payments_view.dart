import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:wallet/wallet.dart';
import 'package:web3dart/web3dart.dart';
import 'package:quanthex_admin/core/router/app_router.dart';
import 'package:quanthex_admin/core/theme/app_colors.dart';
import 'package:quanthex_admin/data/domain/entities/supported_assets.dart';
import 'package:quanthex_admin/data/domain/models/daily_roi_eligible_model.dart';
import 'package:quanthex_admin/data/domain/models/daily_roi_payment_model.dart';
import 'package:quanthex_admin/data/services/transaction_service.dart';
import 'package:quanthex_admin/data/utils/assets/token_factory.dart';
import 'package:quanthex_admin/data/utils/logger.dart';
import 'package:quanthex_admin/presentation/providers/asset_controllers.dart';
import 'package:quanthex_admin/presentation/providers/balance_controller.dart';
import 'package:quanthex_admin/presentation/providers/daily_roi_provider.dart';
import 'package:quanthex_admin/presentation/providers/wallet_controller.dart';
import 'dart:math' as math;

import '../../../core/constants/network_constants.dart';

class DailyRoiPaymentsView extends StatefulWidget {
  const DailyRoiPaymentsView({super.key});

  @override
  State<DailyRoiPaymentsView> createState() => _DailyRoiPaymentsViewState();
}

class _DailyRoiPaymentsViewState extends State<DailyRoiPaymentsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _historyScrollController = ScrollController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<DailyRoiProvider>();
      provider.fetchEligible();
    });
    _historyScrollController.addListener(_onHistoryScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _historyScrollController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.index == 2) {
      final provider = context.read<DailyRoiProvider>();
      if (provider.payments.isEmpty && !provider.isLoadingPayments) {
        provider.fetchPaymentHistory(refresh: true);
      }
    }
  }

  void _onHistoryScroll() {
    if (_historyScrollController.position.pixels >=
        _historyScrollController.position.maxScrollExtent - 200) {
      context.read<DailyRoiProvider>().loadMorePayments();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DailyRoiProvider>(
      builder: (context, provider, _) {
        return Column(
          children: [
            _buildSummaryBanner(provider),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildEligibleTab(provider),
                  _buildAlreadyPaidTab(provider),
                  _buildHistoryTab(provider),
                ],
              ),
            ),
            if (provider.payMessage != null) _buildSnackBanner(provider),
          ],
        );
      },
    );
  }

  // ── Summary Banner ───────────────────────────────────────────────────

  Widget _buildSummaryBanner(DailyRoiProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _SummaryTile(
                  label: 'ROI %',
                  value: '${provider.roiPercentage.toStringAsFixed(2)}%',
                  icon: Icons.percent,
                  color: AppColors.info,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryTile(
                  label: 'Eligible',
                  value: '${provider.eligible.length}',
                  icon: Icons.people_outline,
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryTile(
                  label: 'Total Payout',
                  value: '\$${provider.totalPayoutToday.toStringAsFixed(2)}',
                  icon: Icons.attach_money,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          if (provider.eligible.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: provider.isPayingAll
                    ? null
                    : () => _handlePayAll(context, provider),
                icon: provider.isPayingAll
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded, size: 18),
                label: Text(
                  provider.isPayingAll
                      ? 'Signing & Paying All...'
                      : 'Pay All Eligible (${provider.eligible.length})',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Tab Bar ──────────────────────────────────────────────────────────

  Widget _buildTabBar() {
    return Container(
      color: AppColors.surface,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        indicatorWeight: 2,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle:
            const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        tabs: const [
          Tab(text: 'Eligible Today'),
          Tab(text: 'Already Paid'),
          Tab(text: 'Payment History'),
        ],
      ),
    );
  }

  // ── Eligible Tab ─────────────────────────────────────────────────────

  Widget _buildEligibleTab(DailyRoiProvider provider) {
    if (provider.isLoadingEligible) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (provider.hasEligibleError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              provider.eligibleErrorMessage,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => provider.fetchEligible(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (provider.eligible.isEmpty) {
      return const Center(
        child: Text(
          'No eligible stakings for today.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => provider.fetchEligible(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.eligible.length,
        itemBuilder: (context, index) {
          return _EligibleCard(
            item: provider.eligible[index],
            isPaying: provider.isPaying &&
                provider.payingStakingId == provider.eligible[index].stakingId,
            onPay: () => _navigateToPaySingle(context, provider.eligible[index]),
          );
        },
      ),
    );
  }

  /// Navigate to SendTokenView for a single daily ROI payment.
  Future<void> _navigateToPaySingle(BuildContext context, DailyRoiEligibleModel eligible) async {
    final rwdSymbol = eligible.stakingRewardAssetSymbol;
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
        'dailyRoiEligible': eligible,
      },
    );

    if (result != null && context.mounted) {
      context.read<DailyRoiProvider>().onPaymentCompleted(eligible.stakingId);
    }
  }

  /// Batch sign and submit all eligible daily ROI payments.
  Future<void> _handlePayAll(BuildContext context, DailyRoiProvider provider) async {
    final eligible = List<DailyRoiEligibleModel>.from(provider.eligible);
    if (eligible.isEmpty) return;

    // Confirm with the admin
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pay All Daily ROI'),
        content: Text(
          'This will sign and submit ${eligible.length} transactions on-chain. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Pay All', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    final assetCtr = context.read<AssetController>();
    final balanceCtr = context.read<BalanceController>();
    final walletCtr = context.read<WalletController>();

    if (walletCtr.currentWallet == null) {
      provider.clearPayMessage();
      return;
    }

    // Sign all transactions
    final signedItems = <Map<String, dynamic>>[];
    final tokenFactory = TokenFactory();
    final txService = TransactionService();
    int signFailCount = 0;

    for (final item in eligible) {
      try {
        final rwdSymbol = item.stakingRewardAssetSymbol;
        final matchingCoin = assetCtr.assets.where(
          (c) => c.symbol.toLowerCase() == rwdSymbol.toLowerCase(),
        ).firstOrNull;

        if (matchingCoin == null || matchingCoin.privateKey == null) {
          signFailCount++;
          continue;
        }

        final network = matchingCoin.networkModel!;
        final int decimal = matchingCoin.decimal ?? 18;
        final tokenPrice = balanceCtr.priceQuotes[rwdSymbol.toUpperCase()] ?? 0;
        final double tokenAmount = (tokenPrice > 0)
            ? item.payoutAmount / tokenPrice
            : item.payoutAmount;
        final double totalAmount = tokenAmount * math.pow(10, decimal);

        final credentials = await tokenFactory.getCredentials(matchingCoin.privateKey!);

        // Estimate gas
        final gasPrice = await txService.getChainNetworkFee(
          rpcUrl: network.rpcUrl,
          chainId: network.chainId,
        );

        String signedTx;
        if (matchingCoin.coinType == CoinType.TOKEN || matchingCoin.coinType == CoinType.WRAPPED_TOKEN) {
          final String abi = await rootBundle.loadString("abi/token/token_contract.json");
          final contract = await tokenFactory.intContract(abi, matchingCoin.contractAddress!, matchingCoin.name);
          final sendFunction = contract.function('transfer');
          // Build a preliminary tx to estimate gas
          final prelimTx = Transaction.callContract(
            contract: contract,
            function: sendFunction,
            from: credentials.address,
            parameters: [
              EthereumAddress.fromHex(item.stakingWalletAddress),
              BigInt.from(totalAmount),
            ],
          );
          final gas = await txService.getChainTxFee(
            sender: credentials.address.with0x,
            to: item.stakingWalletAddress,
            rpcUrl: network.rpcUrl,
            data: prelimTx.data,
          );
          final transaction = Transaction.callContract(
            contract: contract,
            function: sendFunction,
            from: credentials.address,
            gasPrice: EtherAmount.inWei(gasPrice),
            maxGas: (gas.toInt() * 4),
            parameters: [
              EthereumAddress.fromHex(item.stakingWalletAddress),
              BigInt.from(totalAmount),
            ],
          );
          signedTx = await txService.signTx(
            transaction: transaction,
            credentials: credentials,
            asset: matchingCoin,
          );
        } else {
          final gas = await txService.getChainTxFee(
            sender: credentials.address.with0x,
            to: item.stakingWalletAddress,
            rpcUrl: network.rpcUrl,
            data: null,
          );
          final tx = Transaction(
            to: EthereumAddress.fromHex(item.stakingWalletAddress),
            value: EtherAmount.fromBigInt(EtherUnit.wei, BigInt.from(totalAmount)),
            from: credentials.address,
            gasPrice: EtherAmount.inWei(gasPrice),
            maxGas: (gas.toInt() * 4),
          );
          signedTx = await txService.signTx(
            transaction: tx,
            credentials: credentials,
            asset: matchingCoin,
          );
        }

        signedItems.add({
          'staking_id': item.stakingId,
          'tx_data': '0x$signedTx',
          'chain_id': network.chainId,
        });
      } catch (e) {
        logger('Error signing tx for ${item.stakingId}: $e', 'DailyRoiPaymentsView');
        signFailCount++;
      }
    }

    if (signedItems.isEmpty) {
      provider.clearPayMessage();
      return;
    }

    // Submit all signed transactions to backend
    if (context.mounted) {
      await provider.payAll(signedItems);
    }
  }

  // ── Already Paid Tab ─────────────────────────────────────────────────

  Widget _buildAlreadyPaidTab(DailyRoiProvider provider) {
    if (provider.isLoadingEligible) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (provider.alreadyPaid.isEmpty) {
      return const Center(
        child: Text(
          'No payments made today yet.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => provider.fetchEligible(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.alreadyPaid.length,
        itemBuilder: (context, index) {
          return _AlreadyPaidCard(item: provider.alreadyPaid[index]);
        },
      ),
    );
  }

  // ── Payment History Tab ──────────────────────────────────────────────

  Widget _buildHistoryTab(DailyRoiProvider provider) {
    return Column(
      children: [
        _buildHistoryFilterBar(provider),
        Expanded(child: _buildHistoryContent(provider)),
      ],
    );
  }

  Widget _buildHistoryFilterBar(DailyRoiProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AppColors.surface,
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => _showHistoryStatusPicker(provider),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: provider.filterStatus != null
                        ? AppColors.primarySurface
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: provider.filterStatus != null
                          ? AppColors.primary
                          : AppColors.border,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        provider.filterStatus != null
                            ? _capitalise(provider.filterStatus!)
                            : 'All Status',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: provider.filterStatus != null
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down,
                        size: 16,
                        color: provider.filterStatus != null
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _pickPaymentDate(provider),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: provider.filterPaymentDate != null
                        ? AppColors.primarySurface
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: provider.filterPaymentDate != null
                          ? AppColors.primary
                          : AppColors.border,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.date_range,
                        size: 14,
                        color: provider.filterPaymentDate != null
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        provider.filterPaymentDate ?? 'Date',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: provider.filterPaymentDate != null
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${provider.paymentsTotal} total',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (provider.hasActiveFilters) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    _emailController.clear();
                    provider.clearFilters();
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Clear',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 36,
            child: TextField(
              controller: _emailController,
              style:
                  const TextStyle(fontSize: 13, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search by email...',
                hintStyle: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textTertiary,
                ),
                prefixIcon: const Icon(Icons.search,
                    size: 18, color: AppColors.textTertiary),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
              onSubmitted: (value) {
                provider.setFilterEmail(
                    value.trim().isEmpty ? null : value.trim());
                provider.applyFilters();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showHistoryStatusPicker(DailyRoiProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All Status'),
              onTap: () {
                provider.setFilterStatus(null);
                provider.applyFilters();
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: const Text('Pending'),
              leading: const Icon(Icons.schedule, color: Colors.orange),
              onTap: () {
                provider.setFilterStatus('pending');
                provider.applyFilters();
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: const Text('Confirmed'),
              leading: const Icon(Icons.check_circle, color: Colors.green),
              onTap: () {
                provider.setFilterStatus('confirmed');
                provider.applyFilters();
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickPaymentDate(DailyRoiProvider provider) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2023),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primary,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final formatted = DateFormat('yyyy-MM-dd').format(picked);
      provider.setFilterPaymentDate(formatted);
      provider.applyFilters();
    }
  }

  Widget _buildHistoryContent(DailyRoiProvider provider) {
    if (provider.isLoadingPayments && provider.payments.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (provider.hasPaymentsError && provider.payments.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              provider.paymentsErrorMessage,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => provider.fetchPaymentHistory(refresh: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (provider.payments.isEmpty) {
      return const Center(
        child: Text(
          'No payment history found.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => provider.fetchPaymentHistory(refresh: true),
      child: ListView.builder(
        controller: _historyScrollController,
        padding: const EdgeInsets.all(16),
        itemCount:
            provider.payments.length + (provider.isLoadingMorePayments ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == provider.payments.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          }
          return _PaymentHistoryCard(payment: provider.payments[index]);
        },
      ),
    );
  }

  Widget _buildSnackBanner(DailyRoiProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: provider.paySuccess
          ? AppColors.statusActiveBackground
          : AppColors.statusInactiveBackground,
      child: Row(
        children: [
          Icon(
            provider.paySuccess ? Icons.check_circle : Icons.error,
            size: 18,
            color: provider.paySuccess ? AppColors.success : AppColors.error,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              provider.payMessage ?? '',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: provider.paySuccess ? AppColors.success : AppColors.error,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => provider.clearPayMessage(),
            child: const Icon(Icons.close, size: 18, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  String _capitalise(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}

// ─── Summary Tile ──────────────────────────────────────────────────────────

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Eligible Card ─────────────────────────────────────────────────────────

class _EligibleCard extends StatelessWidget {
  final DailyRoiEligibleModel item;
  final bool isPaying;
  final VoidCallback onPay;

  const _EligibleCard({
    required this.item,
    required this.isPaying,
    required this.onPay,
  });

  String _truncateAddr(String? value) {
    if (value == null || value.length < 12) return value ?? 'N/A';
    return '${value.substring(0, 6)}...${value.substring(value.length - 6)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.stakingPlan,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '\$${item.payoutAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              SizedBox(
                height: 32,
                child: ElevatedButton(
                  onPressed: isPaying ? null : onPay,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isPaying
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Pay', style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 10),
          _infoRow('Email', item.email),
          const SizedBox(height: 4),
          _infoRow('Staked', '\$${item.stakedAmountFiat.toStringAsFixed(2)}'),
          const SizedBox(height: 4),
          _infoRow('Wallet', _truncateAddr(item.stakingWalletAddress)),
          const SizedBox(height: 4),
          _infoRow('Reward', item.stakingRewardAssetSymbol),
          const SizedBox(height: 4),
          _infoRow('Chain ID', '${item.stakingRewardChainId}'),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ─── Already Paid Card ─────────────────────────────────────────────────────

class _AlreadyPaidCard extends StatelessWidget {
  final DailyRoiEligibleModel item;

  const _AlreadyPaidCard({required this.item});

  String _truncateAddr(String? value) {
    if (value == null || value.length < 12) return value ?? 'N/A';
    return '${value.substring(0, 6)}...${value.substring(value.length - 6)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.stakingPlan,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '\$${item.payoutAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.statusActiveBackground,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _capitalise(item.status ?? 'paid'),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.statusActive,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 10),
          _infoRow('Email', item.email),
          const SizedBox(height: 4),
          _infoRow('Staked', '\$${item.stakedAmountFiat.toStringAsFixed(2)}'),
          const SizedBox(height: 4),
          _infoRow('Wallet', _truncateAddr(item.stakingWalletAddress)),
          const SizedBox(height: 4),
          _infoRow('Reward', item.stakingRewardAssetSymbol),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _capitalise(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}

// ─── Payment History Card ──────────────────────────────────────────────────

class _PaymentHistoryCard extends StatelessWidget {
  final DailyRoiPaymentModel payment;

  const _PaymentHistoryCard({required this.payment});

  String _truncateAddr(String? value) {
    if (value == null || value.length < 12) return value ?? 'N/A';
    return '${value.substring(0, 6)}...${value.substring(value.length - 6)}';
  }

  String _formatDate(String? timestamp) {
    if (timestamp == null || timestamp.isEmpty) return 'N/A';
    try {
      final millis = int.tryParse(timestamp);
      if (millis != null) {
        final date = DateTime.fromMillisecondsSinceEpoch(millis);
        return DateFormat('MMM dd, yyyy').format(date);
      }
      // Try parsing as ISO date string
      final date = DateTime.tryParse(timestamp);
      if (date != null) return DateFormat('MMM dd, yyyy').format(date);
      return timestamp;
    } catch (_) {
      return timestamp;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPending = payment.isPending;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  payment.stakingPlan,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '\$${payment.payoutAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isPending
                      ? AppColors.statusPendingBackground
                      : AppColors.statusActiveBackground,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isPending ? 'Pending' : 'Confirmed',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isPending
                        ? AppColors.statusPending
                        : AppColors.statusActive,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 10),
          _infoRow('Email', payment.email),
          const SizedBox(height: 4),
          _infoRow('Staked', '\$${payment.stakedAmount.toStringAsFixed(2)}'),
          const SizedBox(height: 4),
          _infoRow('ROI %', '${payment.roiPercentage.toStringAsFixed(2)}%'),
          const SizedBox(height: 4),
          _infoRow('Wallet', _truncateAddr(payment.walletAddress)),
          const SizedBox(height: 4),
          _infoRow('Reward', payment.rewardSymbol),
          const SizedBox(height: 4),
          _infoRow('Payment Date', payment.paymentDate),
          const SizedBox(height: 4),
          _infoRow('Created', _formatDate(payment.createdAt)),
          if (payment.txHash != null && payment.txHash!.isNotEmpty) ...[
            const SizedBox(height: 4),
            _infoRow('Tx Hash', _truncateAddr(payment.txHash)),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
