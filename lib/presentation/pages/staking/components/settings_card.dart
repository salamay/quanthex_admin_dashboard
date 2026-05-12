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

class _SettingsCardState extends State<SettingsCard> {
  late TextEditingController _percentageController;
  late TextEditingController _referralsController;
  late bool _isActive;
  bool _isEditing = false;

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
    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.setting.planName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '\$${widget.setting.planAmount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(
                    _isEditing ? Icons.close : Icons.edit_outlined,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () => setState(() => _isEditing = !_isEditing),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(color: AppColors.divider, height: 1),
            const SizedBox(height: 12),

            if (_isEditing) ...[
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
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ] else ...[
              _buildInfoRow('Reward %', '${widget.setting.rewardPercentage.toStringAsFixed(0)}%'),
              const SizedBox(height: 8),
              _buildInfoRow('Current Payout', '\$${widget.setting.computedDoublePayment.toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              _buildInfoRow('Referrals/Cycle', '${widget.setting.referralsPerCycle}'),
            ],
          ],
        ),
      ),
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

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      ],
    );
  }
}
