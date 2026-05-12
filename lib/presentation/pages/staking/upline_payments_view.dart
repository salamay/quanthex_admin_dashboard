import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:quanthex_admin/core/theme/app_colors.dart';
import 'package:quanthex_admin/presentation/providers/upline_payments_provider.dart';
import 'package:quanthex_admin/core/router/app_router.dart';
import 'components/upline_filter_chip.dart';
import 'components/upline_payment_card.dart';

/// Embeddable upline payments view for use inside HomePage drawer layout.
class UplinePaymentsView extends StatefulWidget {
  const UplinePaymentsView({super.key});

  @override
  State<UplinePaymentsView> createState() => _UplinePaymentsViewState();
}

class _UplinePaymentsViewState extends State<UplinePaymentsView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UplinePaymentsProvider>().fetchPayments(refresh: true);
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<UplinePaymentsProvider>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UplinePaymentsProvider>(
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

  Widget _buildFilterBar(UplinePaymentsProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AppColors.surface,
      child: Row(
        children: [
          UplineFilterChip(
            label: provider.selectedStatus ?? 'All Status',
            isActive: provider.selectedStatus != null,
            onTap: () => _showStatusPicker(provider),
          ),
          const SizedBox(width: 8),
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
              onTap: provider.clearFilters,
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
        ],
      ),
    );
  }

  void _showStatusPicker(UplinePaymentsProvider provider) {
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

  Widget _buildContent(UplinePaymentsProvider provider) {
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
          'No upline payments found.',
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
          return UplinePaymentCard(
            payment: provider.payments[index],
            onPay: () {
              context.push(
                AppRoutes.uplinePaymentDetail,
                extra: provider.payments[index],
              );
            },
          );
        },
      ),
    );
  }
}
