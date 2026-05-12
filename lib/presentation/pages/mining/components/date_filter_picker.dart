import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quanthex_admin/core/theme/app_colors.dart';

class DateFilterPicker extends StatelessWidget {
  final DateTime? initialStart;
  final DateTime? initialEnd;
  final ValueChanged<DateTime> onSingleDateSelected;
  final void Function(DateTime start, DateTime end) onDateRangeSelected;

  const DateFilterPicker({
    super.key,
    this.initialStart,
    this.initialEnd,
    required this.onSingleDateSelected,
    required this.onDateRangeSelected,
  });

  Future<void> _pickSingleDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialStart ?? now,
      firstDate: DateTime(2020),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onSingleDateSelected(picked);
    }
  }

  Future<void> _pickDateRange(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: initialStart != null && initialEnd != null
          ? DateTimeRange(start: initialStart!, end: initialEnd!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onDateRangeSelected(picked.start, picked.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter by Date',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20, color: AppColors.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.divider),
          const SizedBox(height: 8),

          // Single date option
          _DateOptionTile(
            icon: Icons.today_outlined,
            title: 'Single Date',
            subtitle: 'Filter by a specific date',
            onTap: () => _pickSingleDate(context),
          ),
          const SizedBox(height: 4),

          // Date range option
          _DateOptionTile(
            icon: Icons.date_range_outlined,
            title: 'Date Range',
            subtitle: 'Filter between two dates',
            onTap: () => _pickDateRange(context),
          ),
        ],
      ),
    );
  }
}

class _DateOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _DateOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primarySurface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: AppColors.primary),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.textTertiary),
    );
  }
}
