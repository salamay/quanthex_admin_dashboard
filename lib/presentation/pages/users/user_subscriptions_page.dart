import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:quanthex_admin/core/theme/app_colors.dart';
import 'package:quanthex_admin/core/di/service_locator.dart';
import 'package:quanthex_admin/data/domain/models/user_model.dart';
import 'package:quanthex_admin/data/domain/models/user_subscription_model.dart';

class UserSubscriptionsPage extends StatefulWidget {
  final UserModel user;

  const UserSubscriptionsPage({super.key, required this.user});

  @override
  State<UserSubscriptionsPage> createState() => _UserSubscriptionsPageState();
}

class _UserSubscriptionsPageState extends State<UserSubscriptionsPage> {
  final List<UserSubscriptionModel> _subscriptions = [];
  int _total = 0;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasError = false;
  bool get _hasMore => _subscriptions.length < _total;

  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _fetchSubscriptions();
  }

  Future<void> _fetchSubscriptions({bool refresh = false}) async {
    if (refresh) {
      _subscriptions.clear();
      _total = 0;
    }
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final repo = ServiceLocator.instance.userRepository;
      final response = await repo.getUserSubscriptions(
        uid: widget.user.uid,
        offset: 0,
        limit: _pageSize,
      );
      _subscriptions.clear();
      _subscriptions.addAll(response.data);
      _total = response.total;
    } catch (e) {
      log('Error fetching subscriptions: $e');
      _hasError = true;
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() => _isLoadingMore = true);

    try {
      final repo = ServiceLocator.instance.userRepository;
      final response = await repo.getUserSubscriptions(
        uid: widget.user.uid,
        offset: _subscriptions.length,
        limit: _pageSize,
      );
      _subscriptions.addAll(response.data);
      _total = response.total;
    } catch (e) {
      log('Error loading more subscriptions: $e');
    } finally {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

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

  String _formatDateShort(String? timestamp) {
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

  void _copyToClipboard(String? text) {
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

  @override
  Widget build(BuildContext context) {
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
          'Subscriptions (${_isLoading ? '...' : _total})',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.refresh, size: 20, color: AppColors.textSecondary),
              onPressed: () => _fetchSubscriptions(refresh: true),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _subscriptions.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_hasError && _subscriptions.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            const Text(
              'Failed to load subscriptions',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => _fetchSubscriptions(refresh: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_subscriptions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.subscriptions_outlined, size: 48, color: AppColors.textTertiary),
            SizedBox(height: 12),
            Text(
              'No subscriptions found',
              style: TextStyle(fontSize: 14, color: AppColors.textTertiary),
            ),
          ],
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.pixels >= notification.metrics.maxScrollExtent - 200) {
          _loadMore();
        }
        return false;
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _subscriptions.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _subscriptions.length) {
            return _isLoadingMore
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink();
          }
          return _buildSubscriptionCard(_subscriptions[index]);
        },
      ),
    );
  }

  Widget _buildSubscriptionCard(UserSubscriptionModel sub) {
    final isActive = sub.isActive;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: package name + status
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.card_membership_rounded, size: 20, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sub.subPackageName ?? 'Unknown Package',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sub.subType ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.statusActive.withOpacity(0.1)
                      : AppColors.statusPending.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  sub.subStatus ?? 'N/A',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isActive ? AppColors.statusActive : AppColors.statusPending,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 14),

          // Details grid
          _buildDetailRow('Subscription ID', sub.subId, copyable: true),
          _buildDetailRow('Asset', '${sub.subAssetName ?? 'N/A'} (${sub.subAssetSymbol ?? ''})'),
          _buildDetailRow('Price', sub.subPrice != null ? '\$${sub.subPrice!.toStringAsFixed(2)}' : 'N/A'),
          _buildDetailRow('Duration', sub.displayDuration),
          _buildDetailRow('Reward Asset', '${sub.subRewardAssetName ?? 'N/A'} (${sub.subRewardAssetSymbol ?? ''})'),
          if (sub.subReferralCode != null && sub.subReferralCode!.isNotEmpty)
            _buildDetailRow('Referral Code', sub.subReferralCode!, copyable: true),
          if (sub.subMiningTag != null && sub.subMiningTag!.isNotEmpty)
            _buildDetailRow('Mining Tag', sub.subMiningTag!),
          if (sub.subWalletAddress != null && sub.subWalletAddress!.isNotEmpty)
            _buildDetailRow(
              'Wallet',
              '${sub.subWalletAddress!.substring(0, 6)}...${sub.subWalletAddress!.substring(sub.subWalletAddress!.length - 4)}',
              copyable: true,
              copyValue: sub.subWalletAddress,
            ),
          _buildDetailRow('Created', _formatDateShort(sub.subCreatedAt)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool copyable = false, String? copyValue}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: copyable ? () => _copyToClipboard(copyValue ?? value) : null,
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (copyable) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.copy, size: 12, color: AppColors.textTertiary),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
