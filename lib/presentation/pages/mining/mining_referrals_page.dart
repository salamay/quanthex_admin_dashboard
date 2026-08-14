import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:quanthex_admin/core/theme/app_colors.dart';
import 'package:quanthex_admin/core/di/service_locator.dart';
import 'package:quanthex_admin/data/domain/models/mining_referral_model.dart';

/// A referral entry placed into a slot, tagged with its type.
class _SlottedReferral {
  final MiningReferralModel referral;
  final bool isDirect;

  _SlottedReferral({required this.referral, required this.isDirect});
}

/// One of the 3 fixed slots.
class _Slot {
  final int level; // 1, 2, 3
  final int capacity; // 6, 36, 216
  final List<_SlottedReferral> entries = [];

  _Slot({required this.level, required this.capacity});

  int get filled => entries.length;
  int get remaining => (capacity - filled).clamp(0, capacity);
  bool get isFull => filled >= capacity;
  double get fillPercent => capacity > 0 ? (filled / capacity).clamp(0, 1) : 0;
}

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

class _MiningReferralsPageState extends State<MiningReferralsPage> {
  List<MiningReferralModel> _directReferrals = [];
  List<MiningReferralModel> _indirectReferrals = [];
  bool _isLoading = false;
  bool _hasError = false;

  late List<_Slot> _slots;

  @override
  void initState() {
    super.initState();
    _slots = [
      _Slot(level: 1, capacity: 6),
      _Slot(level: 2, capacity: 36),
      _Slot(level: 3, capacity: 216),
    ];
    _fetchReferrals();
  }

  Future<void> _fetchReferrals() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final repo = ServiceLocator.instance.miningRepository;
      final results = await Future.wait([
        repo.getDirectReferrals(
          uid: widget.uid,
          subscriptionId: widget.subscriptionId,
        ),
        repo.getIndirectReferrals(
          uid: widget.uid,
          subscriptionId: widget.subscriptionId,
        ),
      ]);

      _directReferrals = results[0];
      _indirectReferrals = results[1];
      _distributeIntoSlots();
    } catch (e) {
      log('Error fetching referrals: $e');
      _hasError = true;
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Distribute referrals into the 3 fixed slots based on their level.
  ///
  /// Level 1 (direct) → naturally Slot 1, overflow to Slot 2 → Slot 3
  /// Level 2 (indirect) → naturally Slot 2, overflow to Slot 3
  /// Level 3+ (indirect) → Slot 3
  ///
  /// Slot 1 is direct-only (no indirect referrals).
  void _distributeIntoSlots() {
    _slots = [
      _Slot(level: 1, capacity: 6),
      _Slot(level: 2, capacity: 36),
      _Slot(level: 3, capacity: 216),
    ];

    // Level 1 referrals (direct) → try Slot 1 → 2 → 3
    for (final ref in _directReferrals) {
      _placeInSlot(ref, startSlot: 0, isDirect: true);
    }

    // Group indirect referrals by their level
    final Map<int, List<MiningReferralModel>> indirectByLevel = {};
    for (final ref in _indirectReferrals) {
      final level = ref.levelFor(widget.subscriptionId);
      final effectiveLevel = level <= 1 ? 2 : level; // safety fallback
      indirectByLevel.putIfAbsent(effectiveLevel, () => []).add(ref);
    }
    final sortedLevels = indirectByLevel.keys.toList()..sort();

    for (final level in sortedLevels) {
      // Level 2 → start at Slot 2 (index 1), overflow to Slot 3
      // Level 3+ → start at Slot 3 (index 2)
      final startIndex = level <= 2 ? 1 : 2;
      for (final ref in indirectByLevel[level]!) {
        _placeInSlot(ref, startSlot: startIndex, isDirect: false);
      }
    }
  }

  /// Place a referral into the first available slot starting from [startSlot].
  void _placeInSlot(MiningReferralModel ref, {required int startSlot, required bool isDirect}) {
    for (int i = startSlot; i < _slots.length; i++) {
      if (!_slots[i].isFull) {
        _slots[i].entries.add(_SlottedReferral(referral: ref, isDirect: isDirect));
        return;
      }
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
    final totalDirect = _directReferrals.length;
    final totalIndirect = _indirectReferrals.length;
    final totalAll = totalDirect + totalIndirect;
    final totalCapacity = 6 + 36 + 216; // 258

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
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _hasError
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                      const SizedBox(height: 12),
                      const Text('Failed to load referrals',
                          style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                      const SizedBox(height: 12),
                      TextButton(onPressed: _fetchReferrals, child: const Text('Retry')),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Summary card
                    _buildSummaryCard(totalDirect, totalIndirect, totalAll, totalCapacity),
                    const SizedBox(height: 16),
                    // Slot sections
                    for (int i = 0; i < _slots.length; i++) ...[
                      if (i > 0) const SizedBox(height: 16),
                      _buildSlotSection(_slots[i]),
                    ],
                    const SizedBox(height: 32),
                  ],
                ),
    );
  }

  Widget _buildSummaryCard(int direct, int indirect, int total, int capacity) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.grid_view_rounded, size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Referral Slots',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
              ),
              Text(
                '$total / $capacity',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildSummaryChip('Direct', direct, AppColors.success),
              const SizedBox(width: 8),
              _buildSummaryChip('Indirect', indirect, AppColors.info),
              const SizedBox(width: 8),
              _buildSummaryChip('Empty', (capacity - total).clamp(0, capacity), AppColors.textTertiary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryChip(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlotSection(_Slot slot) {
    final directInSlot = slot.entries.where((e) => e.isDirect).length;
    final indirectInSlot = slot.entries.where((e) => !e.isDirect).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Slot header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.primaryFaint,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primarySurface),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      slot.level == 1
                          ? Icons.person_rounded
                          : slot.level == 2
                              ? Icons.people_rounded
                              : Icons.groups_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Level ${slot.level}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${slot.filled} / ${slot.capacity}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                    ),
                  ),
                  const Spacer(),
                  // Direct/indirect breakdown
                  if (directInSlot > 0)
                    _buildMiniChip('D: $directInSlot', AppColors.success),
                  if (directInSlot > 0 && indirectInSlot > 0)
                    const SizedBox(width: 4),
                  if (indirectInSlot > 0)
                    _buildMiniChip('I: $indirectInSlot', AppColors.info),
                ],
              ),
              const SizedBox(height: 10),
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  height: 6,
                  child: Stack(
                    children: [
                      // Background
                      Container(
                        width: double.infinity,
                        color: AppColors.primary.withValues(alpha: 0.1),
                      ),
                      // Filled portion
                      FractionallySizedBox(
                        widthFactor: slot.fillPercent,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary,
                                slot.isFull ? AppColors.success : AppColors.primary.withValues(alpha: 0.7),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Referral cards
        if (slot.entries.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                'No referrals in this slot',
                style: TextStyle(fontSize: 13, color: AppColors.textTertiary),
              ),
            ),
          )
        else ...[
          const SizedBox(height: 8),
          ...slot.entries.asMap().entries.map((entry) {
            return _buildReferralCard(entry.value, entry.key + 1);
          }),
        ],
      ],
    );
  }

  Widget _buildMiniChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }

  Widget _buildReferralCard(_SlottedReferral slotted, int index) {
    final referral = slotted.referral;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary),
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
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    // Direct / Indirect badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: (slotted.isDirect ? AppColors.success : AppColors.info).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        slotted.isDirect ? 'Direct' : 'Indirect',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: slotted.isDirect ? AppColors.success : AppColors.info,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
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
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.primary),
                              ),
                              const SizedBox(width: 3),
                              const Icon(Icons.copy, size: 9, color: AppColors.primary),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
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
