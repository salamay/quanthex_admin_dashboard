import 'package:flutter/material.dart';
import 'package:quanthex_admin/core/theme/app_colors.dart';

class DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool copyable;
  final VoidCallback? onCopy;

  const DetailRow({
    super.key,
    required this.label,
    required this.value,
    this.copyable = false,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (copyable && value != 'N/A')
            GestureDetector(
              onTap: onCopy,
              child: const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Icon(Icons.copy, size: 14, color: AppColors.textTertiary),
              ),
            ),
        ],
      ),
    );
  }
}
