import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:quanthex_admin/core/theme/app_colors.dart';
import 'package:quanthex_admin/core/router/app_router.dart';
import 'package:quanthex_admin/data/domain/models/staking_payment_model.dart';
import 'package:quanthex_admin/presentation/providers/staking_payments_provider.dart';

/// Embeddable staking transactions view for use inside HomePage drawer layout.
class StakingTransactionsView extends StatefulWidget {
  const StakingTransactionsView({super.key});

  @override
  State<StakingTransactionsView> createState() =>
      _StakingTransactionsViewState();
}

class _StakingTransactionsViewState extends State<StakingTransactionsView> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StakingPaymentsProvider>().fetchPayments(refresh: true);
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<StakingPaymentsProvider>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StakingPaymentsProvider>(
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

  Widget _buildFilterBar(StakingPaymentsProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AppColors.surface,
      child: Column(
        children: [
          Row(
            children: [
              // Status filter chip
              GestureDetector(
                onTap: () => _showStatusPicker(provider),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: provider.selectedStatus != null
                        ? AppColors.primarySurface
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: provider.selectedStatus != null
                          ? AppColors.primary
                          : AppColors.border,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        provider.selectedStatus != null
                            ? _capitalise(provider.selectedStatus!)
                            : 'All Status',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: provider.selectedStatus != null
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down,
                        size: 16,
                        color: provider.selectedStatus != null
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Date range button
              GestureDetector(
                onTap: () => _pickDateRange(provider),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                        Icons.date_range,
                        size: 14,
                        color: provider.startDate != null
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        provider.startDate != null
                            ? '${DateFormat('MM/dd').format(provider.startDate!)} - ${DateFormat('MM/dd').format(provider.endDate!)}'
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
              Text(
                '${provider.total} total',
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
                provider.setSearchEmail(value.trim().isEmpty ? null : value.trim());
                provider.applyFilters();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showStatusPicker(StakingPaymentsProvider provider) {
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
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateRange(StakingPaymentsProvider provider) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: now,
      initialDateRange: provider.startDate != null && provider.endDate != null
          ? DateTimeRange(start: provider.startDate!, end: provider.endDate!)
          : null,
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
      provider.setDateRange(picked.start, picked.end);
      provider.applyFilters();
    }
  }

  Widget _buildContent(StakingPaymentsProvider provider) {
    if (provider.isLoading && provider.payments.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (provider.hasError && provider.payments.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              provider.errorMessage,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => provider.fetchPayments(refresh: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (provider.payments.isEmpty) {
      return const Center(
        child: Text(
          'No staking transactions found.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => provider.fetchPayments(refresh: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: provider.payments.length + (provider.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == provider.payments.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          }
          return _StakingTransactionCard(
            payment: provider.payments[index],
            onTap: () {
              context.push(
                AppRoutes.stakingPaymentDetail,
                extra: provider.payments[index],
              );
            },
          );
        },
      ),
    );
  }

  String _capitalise(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}

// ---------------------------------------------------------------------------
// Inline transaction card
// ---------------------------------------------------------------------------

class _StakingTransactionCard extends StatelessWidget {
  final StakingPaymentModel payment;
  final VoidCallback onTap;

  const _StakingTransactionCard({
    required this.payment,
    required this.onTap,
  });

  String _truncate(String? value) {
    if (value == null || value.length < 12) return value ?? 'N/A';
    return '${value.substring(0, 6)}...${value.substring(value.length - 6)}';
  }

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

  @override
  Widget build(BuildContext context) {
    final isPending = payment.isPending;
    return GestureDetector(
      onTap: onTap,
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
            // Header row: plan badge + amount + status
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
                    payment.spStakingPlan,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '\$${payment.spAmount.toStringAsFixed(2)}',
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
                        ? Colors.orange.withOpacity(0.15)
                        : Colors.green.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isPending ? 'Pending' : 'Confirmed',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isPending ? Colors.orange : Colors.green,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(color: AppColors.divider, height: 1),
            const SizedBox(height: 10),
            // Info rows
            _infoRow('Email', payment.spEmail),
            const SizedBox(height: 4),
            _infoRow('Wallet', _truncate(payment.stakingWalletAddress)),
            const SizedBox(height: 4),
            _infoRow('Cycle', payment.cycleLabel),
            const SizedBox(height: 4),
            _infoRow('Referrals', '${payment.spReferralCountAtPayment}'),
            const SizedBox(height: 4),
            _infoRow('Reward', payment.spRewardSymbol ?? 'N/A'),
            const SizedBox(height: 4),
            _infoRow('Date', _formatDate(payment.spCreatedAt)),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
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
