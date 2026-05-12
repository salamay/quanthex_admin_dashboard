import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quanthex_admin/core/theme/app_colors.dart';
import 'package:quanthex_admin/presentation/providers/staking_provider.dart';

class StakingFilterBar extends StatelessWidget {
  const StakingFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StakingProvider>(
      builder: (context, provider, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
          ),
          child: Row(
            children: [
              // Plan name filter
              if (provider.planNames.isNotEmpty)
                Expanded(
                  child: Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String?>(
                        value: provider.selectedPlanName,
                        hint: const Text('All Plans', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                        style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('All Plans'),
                          ),
                          ...provider.planNames.map((name) => DropdownMenuItem<String?>(
                                value: name,
                                child: Text(name),
                              )),
                        ],
                        onChanged: (value) {
                          provider.setPlanNameFilter(value);
                          provider.applyFilters();
                        },
                      ),
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              // Refresh button
              IconButton(
                icon: const Icon(Icons.refresh, size: 20, color: AppColors.textSecondary),
                onPressed: () => provider.fetchStakings(refresh: true),
                tooltip: 'Refresh',
              ),
              if (provider.hasActiveFilters)
                TextButton(
                  onPressed: provider.clearFilters,
                  child: const Text('Clear', style: TextStyle(fontSize: 12)),
                ),
            ],
          ),
        );
      },
    );
  }
}
