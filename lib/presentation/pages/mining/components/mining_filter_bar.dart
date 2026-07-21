import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quanthex_admin/core/theme/app_colors.dart';
import 'package:quanthex_admin/presentation/providers/mining_provider.dart';
import 'mining_filter_chip.dart';
import 'package_name_picker.dart';
import 'date_filter_picker.dart';

class MiningFilterBar extends StatefulWidget {
  const MiningFilterBar({super.key});

  @override
  State<MiningFilterBar> createState() => _MiningFilterBarState();
}

class _MiningFilterBarState extends State<MiningFilterBar> {
  final TextEditingController _emailController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _emailController.dispose();
    super.dispose();
  }

  String _formatDateLabel(DateTime? start, DateTime? end) {
    final fmt = DateFormat('MMM dd');
    if (start != null && end != null) {
      if (start.year == end.year && start.month == end.month && start.day == end.day) {
        return fmt.format(start);
      }
      return '${fmt.format(start)} - ${fmt.format(end)}';
    }
    if (start != null) return fmt.format(start);
    if (end != null) return 'Until ${fmt.format(end)}';
    return 'Date';
  }

  void _onEmailChanged(String value, MiningProvider provider) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      provider.setEmailFilter(value);
      provider.applyFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MiningProvider>(
      builder: (context, provider, _) {
        final hasDate = provider.startDate != null || provider.endDate != null;

        // Sync controller if filter was cleared externally
        if (provider.emailFilter == null && _emailController.text.isNotEmpty) {
          _emailController.clear();
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(
              bottom: BorderSide(color: AppColors.border, width: 1),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Email search field
              SizedBox(
                height: 36,
                child: TextField(
                  controller: _emailController,
                  onChanged: (v) => _onEmailChanged(v, provider),
                  style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Search by email...',
                    hintStyle: const TextStyle(fontSize: 13, color: AppColors.textTertiary),
                    prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textTertiary),
                    suffixIcon: _emailController.text.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _emailController.clear();
                              provider.setEmailFilter(null);
                              provider.applyFilters();
                            },
                            child: const Icon(Icons.close, size: 16, color: AppColors.textTertiary),
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
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
                ),
              ),
              const SizedBox(height: 8),
              // Chip filters row
              Row(
                children: [
                  // Package filter
                  MiningFilterChip(
                    label: 'Package',
                    value: provider.selectedPackageName,
                    isActive: provider.selectedPackageName != null,
                    onTap: () {
                      if (provider.selectedPackageName != null) {
                        provider.setPackageNameFilter(null);
                        provider.applyFilters();
                      } else {
                        showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          builder: (_) => PackageNamePicker(
                            packageNames: provider.packageNames,
                            selected: provider.selectedPackageName,
                            onSelected: (name) {
                              provider.setPackageNameFilter(name);
                              provider.applyFilters();
                              Navigator.of(context).pop();
                            },
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(width: 8),

                  // Date filter
                  MiningFilterChip(
                    label: 'Date',
                    value: hasDate
                        ? _formatDateLabel(provider.startDate, provider.endDate)
                        : null,
                    isActive: hasDate,
                    onTap: () {
                      if (hasDate) {
                        provider.setDateRange(null, null);
                        provider.applyFilters();
                      } else {
                        showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          builder: (_) => DateFilterPicker(
                            initialStart: provider.startDate,
                            initialEnd: provider.endDate,
                            onSingleDateSelected: (date) {
                              provider.setDateRange(date, date);
                              provider.applyFilters();
                              Navigator.of(context).pop();
                            },
                            onDateRangeSelected: (start, end) {
                              provider.setDateRange(start, end);
                              provider.applyFilters();
                              Navigator.of(context).pop();
                            },
                          ),
                        );
                      }
                    },
                  ),

                  const Spacer(),

                  // Clear all button
                  if (provider.hasActiveFilters)
                    GestureDetector(
                      onTap: () => provider.clearFilters(),
                      child: const Text(
                        'Clear all',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
