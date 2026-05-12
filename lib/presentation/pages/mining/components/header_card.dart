import 'package:flutter/material.dart';
import 'package:quanthex_admin/core/theme/app_colors.dart';

class HeaderCard extends StatelessWidget {
  final String packageName;
  final String status;
  final String email;
  final String referralCode;

  const HeaderCard({
    super.key,
    required this.packageName,
    required this.status,
    required this.email,
    required this.referralCode,
  });

  Color _statusColor() {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColors.statusActive;
      case 'pending':
        return AppColors.statusPending;
      default:
        return AppColors.statusInactive;
    }
  }

  Color _statusBg() {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColors.statusActiveBackground;
      case 'pending':
        return AppColors.statusPendingBackground;
      default:
        return AppColors.statusInactiveBackground;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  packageName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusBg(),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _statusColor(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.email_outlined, size: 14, color: Colors.white70),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  email,
                  style: const TextStyle(fontSize: 13, color: Colors.white70),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.link, size: 14, color: Colors.white70),
              const SizedBox(width: 6),
              Text(
                'Referral: $referralCode',
                style: const TextStyle(fontSize: 13, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
