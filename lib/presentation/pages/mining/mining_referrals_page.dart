import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:quanthex_admin/core/theme/app_colors.dart';
import 'package:quanthex_admin/core/di/service_locator.dart';
import 'package:quanthex_admin/data/domain/models/mining_referral_model.dart';

class MiningReferralsPage extends StatefulWidget {
  final String uid;
  final String subscriptionId;
  final String packageName;
  final int directCount;
  final int indirectCount;

  const MiningReferralsPage({
    super.key,
    required this.uid,
    required this.subscriptionId,
    required this.packageName,
    required this.directCount,
    required this.indirectCount,
  });

  @override
  State<MiningReferralsPage> createState() => _MiningReferralsPageState();
}

class _MiningReferralsPageState extends State<MiningReferralsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<MiningReferralModel> _directReferrals = [];
  List<MiningReferralModel> _indirectReferrals = [];
  bool _isLoadingDirect = false;
  bool _isLoadingIndirect = false;
  bool _hasDirectError = false;
  bool _hasIndirectError = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchDirectReferrals();
    _fetchIndirectReferrals();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchDirectReferrals() async {
    if (_isLoadingDirect) return;
    setState(() {
      _isLoadingDirect = true;
      _hasDirectError = false;
    });

    try {
      final repo = ServiceLocator.instance.miningRepository;
      _directReferrals = await repo.getDirectReferrals(
        uid: widget.uid,
        subscriptionId: widget.subscriptionId,
      );
    } catch (e) {
      log('Error fetching direct referrals: $e');
      _hasDirectError = true;
    } finally {
      if (mounted) setState(() => _isLoadingDirect = false);
    }
  }

  Future<void> _fetchIndirectReferrals() async {
    if (_isLoadingIndirect) return;
    setState(() {
      _isLoadingIndirect = true;
      _hasIndirectError = false;
    });

    try {
      final repo = ServiceLocator.instance.miningRepository;
      _indirectReferrals = await repo.getIndirectReferrals(
        uid: widget.uid,
        subscriptionId: widget.subscriptionId,
      );

    } catch (e) {
      log('Error fetching indirect referrals: $e');
      _hasIndirectError = true;
    } finally {
      if (mounted) setState(() => _isLoadingIndirect = false);
    }
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
          '${widget.packageName} Referrals',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(49),
          child: Column(
            children: [
              Container(color: AppColors.border, height: 1),
              TabBar(
                controller: _tabController,
                indicatorColor: AppColors.primary,
                indicatorWeight: 2.5,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                tabs: [
                  Tab(text: 'Direct (${_isLoadingDirect ? '...' : _directReferrals.length})'),
                  Tab(text: 'Indirect (${_isLoadingIndirect ? '...' : _indirectReferrals.length})'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReferralList(
            referrals: _directReferrals,
            isLoading: _isLoadingDirect,
            hasError: _hasDirectError,
            onRetry: _fetchDirectReferrals,
            emptyMessage: 'No direct referrals',
          ),
          _buildGroupedIndirectList(),
        ],
      ),
    );
  }

  Widget _buildGroupedIndirectList() {
    if (_isLoadingIndirect) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_hasIndirectError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            const Text(
              'Failed to load referrals',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextButton(onPressed: _fetchIndirectReferrals, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_indirectReferrals.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline, size: 48, color: AppColors.textTertiary),
            SizedBox(height: 12),
            Text(
              'No indirect referrals',
              style: TextStyle(fontSize: 14, color: AppColors.textTertiary),
            ),
          ],
        ),
      );
    }

    // Group by level relative to the subscription being viewed
    // Level 1 = direct (skip), level 2+ = indirect
    final Map<int, List<MiningReferralModel>> grouped = {};
    for (final ref in _indirectReferrals) {
      final level = ref.levelFor(widget.subscriptionId);
      if (level <= 1) continue;
      grouped.putIfAbsent(level, () => []).add(ref);
    }
    final sortedLevels = grouped.keys.toList()..sort();

    if (sortedLevels.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline, size: 48, color: AppColors.textTertiary),
            SizedBox(height: 12),
            Text(
              'No indirect referrals',
              style: TextStyle(fontSize: 14, color: AppColors.textTertiary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedLevels.length,
      itemBuilder: (context, sectionIndex) {
        final level = sortedLevels[sectionIndex];
        final refs = grouped[level]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (sectionIndex > 0) const SizedBox(height: 12),
            // Level header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primaryFaint,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primarySurface),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      level == 2
                          ? Icons.person_rounded
                          : level == 3
                              ? Icons.people_rounded
                              : Icons.groups_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Level $level',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${refs.length}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ...refs.asMap().entries.map((entry) {
              return _buildReferralCard(entry.value, entry.key + 1);
            }),
          ],
        );
      },
    );
  }

  Widget _buildReferralList({
    required List<MiningReferralModel> referrals,
    required bool isLoading,
    required bool hasError,
    required VoidCallback onRetry,
    required String emptyMessage,
  }) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (hasError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            const Text(
              'Failed to load referrals',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (referrals.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.people_outline, size: 48, color: AppColors.textTertiary),
            const SizedBox(height: 12),
            Text(
              emptyMessage,
              style: const TextStyle(fontSize: 14, color: AppColors.textTertiary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: referrals.length,
      itemBuilder: (context, index) {
        return _buildReferralCard(referrals[index], index + 1);
      },
    );
  }

  Widget _buildReferralCard(MiningReferralModel referral, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Index badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primaryFaint,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              '$index',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  referral.referreeEmail ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (referral.referreeReferralCode != null &&
                        referral.referreeReferralCode!.isNotEmpty) ...[
                      GestureDetector(
                        onTap: () => _copyToClipboard(referral.referreeReferralCode),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryFaint,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                referral.referreeReferralCode!,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 3),
                              const Icon(Icons.copy, size: 9, color: AppColors.primary),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Builder(builder: (_) {
                      final level = referral.levelFor(widget.subscriptionId);
                      if (level <= 0) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.info.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Level $level',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.info,
                            ),
                          ),
                        ),
                      );
                    }),
                    Icon(Icons.calendar_today, size: 10, color: AppColors.textTertiary),
                    const SizedBox(width: 3),
                    Text(
                      _formatDate(referral.referralCreatedAt),
                      style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
