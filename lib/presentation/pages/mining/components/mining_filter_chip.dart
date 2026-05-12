import 'package:flutter/material.dart';
import 'package:quanthex_admin/core/theme/app_colors.dart';

class MiningFilterChip extends StatelessWidget {
  final String label;
  final String? value;
  final VoidCallback onTap;
  final bool isActive;

  const MiningFilterChip({
    super.key,
    required this.label,
    this.value,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primarySurface : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.border,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              label == 'Package' ? Icons.inventory_2_outlined : Icons.calendar_today_outlined,
              size: 14,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              value ?? label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
            if (isActive) ...[
              const SizedBox(width: 4),
              Icon(Icons.close, size: 14, color: AppColors.primary),
            ] else ...[
              const SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.textSecondary),
            ],
          ],
        ),
      ),
    );
  }
}
