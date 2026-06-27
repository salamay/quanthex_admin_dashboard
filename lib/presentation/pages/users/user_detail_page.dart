import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:quanthex_admin/core/theme/app_colors.dart';
import 'package:quanthex_admin/data/domain/models/user_model.dart';
import 'package:go_router/go_router.dart';
import 'package:quanthex_admin/core/router/app_router.dart';
import 'package:quanthex_admin/presentation/pages/mining/components/section_card.dart';
import 'package:quanthex_admin/presentation/pages/mining/components/detail_row.dart';

class UserDetailPage extends StatelessWidget {
  final UserModel user;

  const UserDetailPage({super.key, required this.user});

  String _formatDate(String? timestamp) {
    if (timestamp == null) return 'N/A';
    try {
      final millis = int.tryParse(timestamp);
      if (millis == null) return 'N/A';
      final date = DateTime.fromMillisecondsSinceEpoch(millis);
      return DateFormat('MMM dd, yyyy • hh:mm a').format(date);
    } catch (_) {
      return 'N/A';
    }
  }

  void _copyToClipboard(BuildContext context, String? text) {
    if (text == null || text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Copied to clipboard'),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'User Detail',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(context),
            const SizedBox(height: 16),

            // Account Information
            SectionCard(
              title: 'Account Information',
              icon: Icons.account_circle_outlined,
              children: [
                DetailRow(
                  label: 'User ID',
                  value: user.uid,
                  copyable: true,
                  onCopy: () => _copyToClipboard(context, user.uid),
                ),
                DetailRow(label: 'Email', value: user.email),
                DetailRow(label: 'Status', value: user.accountStatus),
                DetailRow(label: 'Roles', value: user.roles),
                DetailRow(
                  label: 'Registration Method',
                  value: user.regVia ?? 'N/A',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Profile Information
            SectionCard(
              title: 'Profile Information',
              icon: Icons.badge_outlined,
              children: [
                DetailRow(
                  label: 'Referral Code',
                  value: user.referralCode ?? 'N/A',
                  copyable: user.referralCode != null && user.referralCode!.isNotEmpty,
                  onCopy: () => _copyToClipboard(context, user.referralCode),
                ),
                DetailRow(
                  label: 'Account Created',
                  value: _formatDate(user.userCreatedAt),
                ),
                DetailRow(
                  label: 'Profile Created',
                  value: _formatDate(user.profileCreatedAt),
                ),
                DetailRow(
                  label: 'Profile Updated',
                  value: _formatDate(user.profileUpdatedAt),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // View Subscriptions button
            _buildSubscriptionsButton(context),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.person_rounded,
              size: 28,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            user.email,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: user.isActive
                      ? AppColors.statusActive.withOpacity(0.1)
                      : AppColors.statusPending.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  user.accountStatus,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: user.isActive ? AppColors.statusActive : AppColors.statusPending,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryFaint,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  user.roles,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionsButton(BuildContext context) {
    return InkWell(
      onTap: () => context.push(AppRoutes.userSubscriptions, extra: user),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.card_membership_rounded, size: 18, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'View Subscriptions',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 22, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
