import 'package:flutter/material.dart';
import 'package:quanthex_admin/core/theme/app_colors.dart';

class LoadMoreIndicator extends StatelessWidget {
  const LoadMoreIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
