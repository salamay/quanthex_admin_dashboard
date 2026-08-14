import 'package:flutter/material.dart';
import 'package:quanthex_admin/core/theme/app_colors.dart';
import 'package:quanthex_admin/data/domain/models/staking_settings_model.dart';

class SettingsCard extends StatefulWidget {
  final StakingSettingsModel setting;
  final Function(double? rewardPercentage, int? referralsPerCycle, bool? isActive) onUpdate;

  const SettingsCard({super.key, required this.setting, required this.onUpdate});

  @override
  State<SettingsCard> createState() => _SettingsCardState();
}

class _SettingsCardState extends State<SettingsCard> with SingleTickerProviderStateMixin {
  late TextEditingController _percentageController;
  late TextEditingController _referralsController;
  late bool _isActive;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _percentageController = TextEditingController(
      text: widget.setting.rewardPercentage.toStringAsFixed(0),
    );
    _referralsController = TextEditingController(
      text: widget.setting.referralsPerCycle.toString(),
    );
    _isActive = widget.setting.isActive;
  }

  @override
  void didUpdateWidget(covariant SettingsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.setting.ssId != widget.setting.ssId) {
      _percentageController.text = widget.setting.rewardPercentage.toStringAsFixed(0);
      _referralsController.text = widget.setting.referralsPerCycle.toString();
      _isActive = widget.setting.isActive;
    }
  }

  @override
  void dispose() {
    _percentageController.dispose();
    _referralsController.dispose();
    super.dispose();
  }

  void _save() {
    final percentage = double.tryParse(_percentageController.text);
    final referrals = int.tryParse(_referralsController.text);
    widget.onUpdate(percentage, referrals, _isActive);
    setState(() => _isExpanded = false);
  }

  static IconData _iconForPlan(String name) {
    switch (name.toLowerCase()) {
      case 'starter':
        return Icons.rocket_launch_rounded;
      case 'boost':
        return Icons.bolt_rounded;
      case 'growth':
        return Icons.trending_up_rounded;
      case 'advance':
        return Icons.diamond_rounded;
      case 'pro':
        return Icons.star_rounded;
      case 'mega':
        return Icons.workspace_premium_rounded;
      default:
        return Icons.hexagon_rounded;
    }
  }

  static Color _colorForPlan(String name) {
    switch (name.toLowerCase()) {
      case 'starter':
        return const Color(0xFF2196F3);
      case 'boost':
        return const Color(0xFFFF9800);
      case 'growth':
        return const Color(0xFF4CAF50);
      case 'advance':
        return const Color(0xFF9C27B0);
      case 'pro':
        return const Color(0xFFFFB300);
      case 'mega':
        return const Color(0xFFF44336);
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorForPlan(widget.setting.planName);
    final icon = _iconForPlan(widget.setting.planName);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // ── Compact card row ──
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  // Colored icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, size: 22, color: color),
                  ),
                  const SizedBox(width: 14),
                  // Name & price
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.setting.planName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '\$${widget.setting.planAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Active badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: widget.setting.isActive
                          ? AppColors.statusActiveBackground
                          : AppColors.statusInactiveBackground,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.setting.isActive ? 'active' : 'inactive',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: widget.setting.isActive
                            ? AppColors.statusActive
                            : AppColors.statusInactive,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Chevron
                  AnimatedRotation(
                    turns: _isExpanded ? 0.25 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      size: 22,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Expandable edit section ──
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _buildExpandedContent(color),
            crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent(Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 14),
          // Info rows
          _buildInfoRow('Reward %', '${widget.setting.rewardPercentage.toStringAsFixed(0)}%'),
          const SizedBox(height: 8),
          _buildInfoRow('Current Payout', '\$${widget.setting.computedDoublePayment.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _buildInfoRow('Referrals/Cycle', '${widget.setting.referralsPerCycle}'),
          const SizedBox(height: 16),
          // Edit fields
          _buildEditField(
            label: 'Reward Percentage (%)',
            controller: _percentageController,
            keyboardType: TextInputType.number,
            helperText: '100% = full double (\$${(widget.setting.planAmount * 2).toStringAsFixed(0)}), '
                '50% = \$${(widget.setting.planAmount).toStringAsFixed(0)}',
          ),
          const SizedBox(height: 12),
          _buildEditField(
            label: 'Referrals Per Cycle',
            controller: _referralsController,
            keyboardType: TextInputType.number,
            isEnabled: false,
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _buildEditField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    String? helperText,
    bool isEnabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        TextField(
          enabled: isEnabled,
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            helperText: helperText,
            helperStyle: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            helperMaxLines: 2,
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
      ],
    );
  }
}
