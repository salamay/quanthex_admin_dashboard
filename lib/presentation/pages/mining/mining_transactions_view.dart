import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:quanthex_admin/core/theme/app_colors.dart';
import 'package:quanthex_admin/core/router/app_router.dart';
import 'package:quanthex_admin/data/domain/models/mining_payment_model.dart';
import 'package:quanthex_admin/presentation/providers/mining_payments_provider.dart';
import 'package:quanthex_admin/presentation/widgets/load_more_indicator.dart';
import 'package:quanthex_admin/presentation/pages/staking/components/upline_filter_chip.dart';
import 'components/mining_list_shimmer.dart';
import 'components/mining_empty_state.dart';
import 'components/mining_error_state.dart';

/// Embeddable mining transactions view (no Scaffold) for use inside HomePage drawer layout.
class MiningTransactionsView extends StatefulWidget {
  const MiningTransactionsView({super.key});

  @override
  State<MiningTransactionsView> createState() => _MiningTransactionsViewState();
}

class _MiningTransactionsViewState extends State<MiningTransactionsView> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MiningPaymentsProvider>().fetchPayments(refresh: true);
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<MiningPaymentsProvider>().loadMore();
    }
  }

  String _formatDate(String? timestamp) {
    if (timestamp == null || timestamp.isEmpty) return 'N/A';
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

  @override
  Widget build(BuildContext context) {
    return Consumer<MiningPaymentsProvider>(
      builder: (context, provider, _) {
        return Column(
          children: [
            _buildFilterBar(provider),
            Expanded(child: _buildContent(provider)),
          ],
        );
      },
    );
  }

  Widget _buildFilterBar(MiningPaymentsProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AppColors.surface,
      child: Column(
        children: [
          Row(
            children: [
              UplineFilterChip(
                label: provider.selectedStatus != null
                    ? _capitalizeStatus(provider.selectedStatus!)
                    : 'All Status',
                isActive: provider.selectedStatus != null,
                onTap: () => _showStatusPicker(provider),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _showDateRangePicker(provider),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: provider.startDate != null
                        ? AppColors.primarySurface
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: provider.startDate != null
                          ? AppColors.primary
                          : AppColors.border,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.date_range_rounded,
                        size: 14,
                        color: provider.startDate != null
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        provider.startDate != null
                            ? '${DateFormat('MM/dd').format(provider.startDate!)} - ${DateFormat('MM/dd').format(provider.endDate ?? DateTime.now())}'
                            : 'Date',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: provider.startDate != null
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              if (provider.hasActiveFilters)
                GestureDetector(
                  onTap: () {
                    _emailController.clear();
                    provider.clearFilters();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
          ),
          const SizedBox(height: 8),
          // Email search field
          SizedBox(
            height: 36,
            child: TextField(
              controller: _emailController,
              style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search by email...',
                hintStyle: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textTertiary,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  size: 18,
                  color: AppColors.textTertiary,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
              onSubmitted: (value) {
                provider.setSearchEmail(value.isEmpty ? null : value);
                provider.applyFilters();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showStatusPicker(MiningPaymentsProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All Status'),
              onTap: () {
                provider.setStatusFilter(null);
                provider.applyFilters();
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: const Text('Pending'),
              leading: const Icon(Icons.schedule, color: Colors.orange),
              onTap: () {
                provider.setStatusFilter('pending');
                provider.applyFilters();
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: const Text('Confirmed'),
              leading: const Icon(Icons.check_circle, color: Colors.green),
              onTap: () {
                provider.setStatusFilter('confirmed');
                provider.applyFilters();
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: const Text('Failed'),
              leading: const Icon(Icons.cancel, color: Colors.red),
              onTap: () {
                provider.setStatusFilter('failed');
                provider.applyFilters();
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDateRangePicker(MiningPaymentsProvider provider) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: now,
      initialDateRange: provider.startDate != null && provider.endDate != null
          ? DateTimeRange(start: provider.startDate!, end: provider.endDate!)
          : DateTimeRange(
              start: now.subtract(const Duration(days: 30)),
              end: now,
            ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      provider.setDateRange(picked.start, picked.end);
      provider.applyFilters();
    }
  }

  Widget _buildContent(MiningPaymentsProvider provider) {
    if (provider.isLoading && provider.payments.isEmpty) {
      return const MiningListShimmer();
    }

    if (provider.hasError && provider.payments.isEmpty) {
      return MiningErrorState(
        message: provider.errorMessage,
        onRetry: () => provider.fetchPayments(refresh: true),
      );
    }

    if (provider.payments.isEmpty) {
      return const MiningEmptyState();
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => provider.fetchPayments(refresh: true),
      child: Column(
        children: [
          // Total count header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text(
              'Showing ${provider.payments.length} of ${provider.total} transactions',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          // List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount:
                  provider.payments.length + (provider.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == provider.payments.length) {
                  return const LoadMoreIndicator();
                }
                return _buildTransactionCard(provider.payments[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(MiningPaymentModel payment) {
    return GestureDetector(
      onTap: () {
        context.push(AppRoutes.miningPaymentDetail, extra: payment);
      },
      child: Container(
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
            // Header row: package badge + amount + status
            Row(
              children: [
                // Package name badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    payment.subPackageName ?? 'Unknown',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '\$${payment.mpAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                _buildStatusBadge(payment),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: AppColors.divider, height: 1),
            const SizedBox(height: 10),
            // Info rows
            _buildInfoLine(
              Icons.email_outlined,
              'Email',
              payment.userEmail ?? 'N/A',
            ),
            const SizedBox(height: 6),
            _buildInfoLine(
              Icons.account_balance_wallet_outlined,
              'Wallet',
              _truncateAddress(payment.miningWalletAddress),
            ),
            const SizedBox(height: 6),
            _buildInfoLine(
              Icons.layers_outlined,
              'Tier',
              payment.tierLabel,
            ),
            const SizedBox(height: 6),
            _buildInfoLine(
              Icons.people_outline,
              'Referrals',
              '${payment.mpReferralCountAtPayment}',
            ),
            const SizedBox(height: 6),
            _buildInfoLine(
              Icons.token_outlined,
              'Reward',
              payment.mpRewardSymbol ?? payment.subRewardAssetSymbol ?? 'N/A',
            ),
            const SizedBox(height: 6),
            _buildInfoLine(
              Icons.calendar_today_outlined,
              'Date',
              _formatDate(payment.mpCreatedAt),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(MiningPaymentModel payment) {
    Color bgColor;
    Color textColor;
    String label;

    if (payment.isPending) {
      bgColor = AppColors.statusPendingBackground;
      textColor = AppColors.statusPending;
      label = 'Pending';
    } else if (payment.isConfirmed) {
      bgColor = AppColors.statusActiveBackground;
      textColor = AppColors.statusActive;
      label = 'Confirmed';
    } else {
      bgColor = AppColors.statusInactiveBackground;
      textColor = AppColors.error;
      label = 'Failed';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildInfoLine(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textTertiary),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
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

  String _capitalizeStatus(String status) {
    if (status.isEmpty) return status;
    return status[0].toUpperCase() + status.substring(1).toLowerCase();
  }
}
