import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quanthex_admin/core/theme/app_colors.dart';
import 'package:quanthex_admin/data/domain/models/daily_roi_settings_model.dart';
import 'package:quanthex_admin/presentation/providers/staking_settings_provider.dart';
import 'components/settings_card.dart';

/// Embeddable staking settings view for use inside HomePage drawer layout.
class StakingSettingsView extends StatefulWidget {
  const StakingSettingsView({super.key});

  @override
  State<StakingSettingsView> createState() => _StakingSettingsViewState();
}

class _StakingSettingsViewState extends State<StakingSettingsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StakingSettingsProvider>().fetchSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StakingSettingsProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        if (provider.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(provider.errorMessage, style: const TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: provider.fetchSettings,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (provider.settings.isEmpty) {
          return const Center(
            child: Text('No staking settings found.', style: TextStyle(color: AppColors.textSecondary)),
          );
        }

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: provider.fetchSettings,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Global Daily ROI card
              _DailyRoiCard(
                dailyRoi: provider.dailyRoi,
                isLoading: provider.isDailyRoiLoading,
                onUpdate: (percentage, isActive) async {
                  final success = await provider.updateDailyRoi(
                    dailyRoiPercentage: percentage,
                    isActive: isActive,
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(success
                            ? 'Daily ROI updated successfully'
                            : 'Failed to update daily ROI'),
                        backgroundColor:
                            success ? AppColors.statusActive : AppColors.error,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              // Section header for packages
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  'Packages',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              // Plan settings cards
              ...provider.settings.map((setting) => SettingsCard(
                    setting: setting,
                    onUpdate:
                        (rewardPercentage, referralsPerCycle, isActive) async {
                      final success = await provider.updateSetting(
                        ssId: setting.ssId,
                        rewardPercentage: rewardPercentage,
                        referralsPerCycle: referralsPerCycle,
                        isActive: isActive,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(success
                                ? 'Setting updated successfully'
                                : 'Failed to update setting'),
                            backgroundColor: success
                                ? AppColors.statusActive
                                : AppColors.error,
                          ),
                        );
                      }
                    },
                  )),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Daily ROI Card
// ---------------------------------------------------------------------------

class _DailyRoiCard extends StatefulWidget {
  final DailyRoiSettingsModel? dailyRoi;
  final bool isLoading;
  final Future<void> Function(double? percentage, bool? isActive) onUpdate;

  const _DailyRoiCard({
    required this.dailyRoi,
    required this.isLoading,
    required this.onUpdate,
  });

  @override
  State<_DailyRoiCard> createState() => _DailyRoiCardState();
}

class _DailyRoiCardState extends State<_DailyRoiCard> {
  late TextEditingController _roiController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _roiController = TextEditingController(
      text: widget.dailyRoi?.dailyRoiPercentage.toString() ?? '0.5',
    );
  }

  @override
  void didUpdateWidget(covariant _DailyRoiCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isEditing && widget.dailyRoi != oldWidget.dailyRoi) {
      _roiController.text =
          widget.dailyRoi?.dailyRoiPercentage.toString() ?? '0.5';
    }
  }

  @override
  void dispose() {
    _roiController.dispose();
    super.dispose();
  }

  void _save() {
    final percentage = double.tryParse(_roiController.text);
    if (percentage == null || percentage < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid percentage'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    widget.onUpdate(percentage, null);
    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    final roi = widget.dailyRoi;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.trending_up_rounded,
                        size: 16, color: AppColors.primary),
                    SizedBox(width: 4),
                    Text(
                      'Daily ROI',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (roi != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: roi.isActive
                        ? AppColors.statusActiveBackground
                        : AppColors.statusInactiveBackground,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    roi.isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: roi.isActive
                          ? AppColors.statusActive
                          : AppColors.error,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  _isEditing ? Icons.close : Icons.edit_outlined,
                  size: 20,
                  color: AppColors.primary,
                ),
                onPressed: () => setState(() => _isEditing = !_isEditing),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Divider(color: AppColors.primary.withOpacity(0.15), height: 1),
          const SizedBox(height: 12),

          if (roi == null)
            const Text(
              'Daily ROI settings not configured. Run the migration first.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            )
          else if (_isEditing) ...[
            const Text(
              'Daily ROI Percentage (%)',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _roiController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style:
                  const TextStyle(fontSize: 14, color: AppColors.textPrimary),
              decoration: InputDecoration(
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                helperText:
                    'Applied globally to all staking plans. E.g. 0.5 = 0.5% daily.',
                helperStyle: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary),
                helperMaxLines: 2,
                suffixText: '%',
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
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: widget.isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: widget.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Save Daily ROI',
                        style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Current Daily ROI',
                  style:
                      TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                Text(
                  '${roi.dailyRoiPercentage}%',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Applied globally to all staking plans',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary.withOpacity(0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
