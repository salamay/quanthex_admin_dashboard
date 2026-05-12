import 'package:flutter/material.dart';
import 'package:quanthex_admin/core/constants/package_constants.dart';
import 'package:quanthex_admin/core/theme/app_colors.dart';

class PackageNamePicker extends StatelessWidget {
  final List<String> packageNames;
  final String? selected;
  final ValueChanged<String> onSelected;

  const PackageNamePicker({
    super.key,
    required this.packageNames,
    this.selected,
    required this.onSelected,
  });

  List<String> get _effectivePackages =>
      packageNames.isNotEmpty ? packageNames : PackageConstants.allPackages;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 16),
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
                  'Select Package',
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

          // Package list — use server list if available, otherwise hardcoded
          if (_effectivePackages.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text(
                  'No packages available',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            )
          else
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _effectivePackages.length,
                itemBuilder: (context, index) {
                  final name = _effectivePackages[index];
                  final isSelected = name == selected;

                  return ListTile(
                    onTap: () => onSelected(name),
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primarySurface
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.inventory_2_outlined,
                        size: 18,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                    title: Text(
                      name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, size: 20, color: AppColors.primary)
                        : null,
                  );
                },
              ),
            ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
