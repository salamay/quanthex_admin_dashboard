import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:quanthex_admin/core/router/app_router.dart';
import 'package:quanthex_admin/core/theme/app_colors.dart';
import 'package:quanthex_admin/presentation/providers/wallet_controller.dart';
import 'package:quanthex_admin/presentation/providers/auth_provider.dart';
import 'package:quanthex_admin/core/constants/package_constants.dart';
import 'package:quanthex_admin/presentation/pages/home/home_view.dart';
import 'package:quanthex_admin/presentation/pages/mining/minings_page.dart';
import 'package:quanthex_admin/presentation/pages/staking/stakings_view.dart';
import 'package:quanthex_admin/presentation/pages/staking/staking_settings_page.dart';
import 'package:quanthex_admin/presentation/pages/staking/upline_payments_view.dart';
import 'package:quanthex_admin/presentation/pages/mining/mining_transactions_view.dart';
import 'package:quanthex_admin/presentation/pages/staking/staking_transactions_view.dart';
import 'package:quanthex_admin/presentation/pages/staking/daily_roi_payments_view.dart';
import 'package:quanthex_admin/presentation/pages/users/users_view.dart';
import 'package:quanthex_admin/presentation/pages/users/completed_hash_users_page.dart';

enum DrawerItem { users, completedHash, walletOverview, minings, stakings, stakingSettings, uplinePayments, dailyRoiPayments, miningTransactions, stakingTransactions }

// ─── Package visual helpers ──────────────────────────────────────────────────

IconData _iconForPlan(String name) {
  final n = name.toLowerCase();
  if (n.startsWith('starter')) return Icons.rocket_launch_rounded;
  if (n.startsWith('boost')) return Icons.bolt_rounded;
  if (n.startsWith('growth')) return Icons.trending_up_rounded;
  if (n.startsWith('advance')) return Icons.diamond_rounded;
  if (n.startsWith('pro')) return Icons.star_rounded;
  if (n.startsWith('mega')) return Icons.workspace_premium_rounded;
  return Icons.hexagon_rounded;
}

Color _colorForPlan(String name) {
  final n = name.toLowerCase();
  if (n.startsWith('starter')) return const Color(0xFF2196F3);
  if (n.startsWith('boost')) return const Color(0xFFFF9800);
  if (n.startsWith('growth')) return const Color(0xFF4CAF50);
  if (n.startsWith('advance')) return const Color(0xFF9C27B0);
  if (n.startsWith('pro')) return const Color(0xFFFFB300);
  if (n.startsWith('mega')) return const Color(0xFFF44336);
  return AppColors.primary;
}

// ─── HomePage ────────────────────────────────────────────────────────────────

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DrawerItem _selectedItem = DrawerItem.walletOverview;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isCompletedHashExpanded = false;
  String? _selectedPackageName;

  @override
  void initState() {
    super.initState();
  }

  String get _title {
    switch (_selectedItem) {
      case DrawerItem.users:
        return 'All Users';
      case DrawerItem.completedHash:
        return _selectedPackageName != null
            ? 'Completed Hash · $_selectedPackageName'
            : 'Completed Hash';
      case DrawerItem.walletOverview:
        return 'Wallet Overview';
      case DrawerItem.minings:
        return 'All Minings';
      case DrawerItem.stakings:
        return 'All Stakings';
      case DrawerItem.stakingSettings:
        return 'Staking Settings';
      case DrawerItem.uplinePayments:
        return 'Upline Payments';
      case DrawerItem.dailyRoiPayments:
        return 'Daily ROI Payments';
      case DrawerItem.miningTransactions:
        return 'Mining Transactions';
      case DrawerItem.stakingTransactions:
        return 'Staking Transactions';
    }
  }

  void _onItemSelected(DrawerItem item) {
    setState(() {
      _selectedItem = item;
      if (item != DrawerItem.completedHash) {
        _selectedPackageName = null;
      }
    });
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
  }

  void _onPackageSelected(String packageName) {
    setState(() {
      _selectedItem = DrawerItem.completedHash;
      _selectedPackageName = packageName;
    });
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Logout',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await context.read<AuthProvider>().logout();
      await context.read<WalletController>().clear();
      if (mounted) {
        context.go(AppRoutes.signIn);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth >= 800;

    if (isWideScreen) {
      return _buildWideLayout();
    }
    return _buildNarrowLayout();
  }

  // ── Mobile / Narrow Layout ──────────────────────────────────────────

  Widget _buildNarrowLayout() {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: false,
        title: Text(
          _title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, color: AppColors.textPrimary),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded,
                color: AppColors.textSecondary),
            tooltip: 'Logout',
            onPressed: _handleLogout,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      ),
      drawer: _buildDrawer(),
      body: _buildBody(),
    );
  }

  // ── Wide / Desktop Layout ───────────────────────────────────────────

  Widget _buildWideLayout() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          _buildSideNav(),
          Container(width: 1, color: AppColors.border),
          Expanded(
            child: Column(
              children: [
                Container(
                  color: AppColors.surface,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: [
                      Text(
                        _title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.logout_rounded,
                            color: AppColors.textSecondary),
                        tooltip: 'Logout',
                        onPressed: _handleLogout,
                      ),
                    ],
                  ),
                ),
                Container(height: 1, color: AppColors.border),
                Expanded(child: _buildBody()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Side Navigation (Desktop) ───────────────────────────────────────

  Widget _buildSideNav() {
    return Container(
      width: 260,
      color: AppColors.surface,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBrandHeader(),
              Container(height: 1, color: AppColors.border),
              const SizedBox(height: 8),
              _buildNavItem(
                icon: Icons.people_rounded,
                label: 'Users',
                item: DrawerItem.users,
                iconColor: const Color(0xFF2196F3),
              ),
              // ── Expandable Completed Hash ──
              _buildExpandableNavItem(
                icon: Icons.verified_rounded,
                label: 'Completed Hash',
                iconColor: const Color(0xFF4CAF50),
                isParentSelected: _selectedItem == DrawerItem.completedHash,
              ),
              _buildNavItem(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Wallet Overview',
                item: DrawerItem.walletOverview,
                iconColor: AppColors.primary,
              ),
              _buildNavItem(
                icon: Icons.bar_chart_rounded,
                label: 'Minings',
                item: DrawerItem.minings,
                iconColor: const Color(0xFFFF9800),
              ),
              _buildNavItem(
                icon: Icons.stacked_line_chart_rounded,
                label: 'Stakings',
                item: DrawerItem.stakings,
                iconColor: const Color(0xFF9C27B0),
              ),
              _buildNavItem(
                icon: Icons.settings_outlined,
                label: 'Staking Settings',
                item: DrawerItem.stakingSettings,
                iconColor: const Color(0xFF607D8B),
              ),
              _buildNavItem(
                icon: Icons.people_outline_rounded,
                label: 'Upline Payments',
                item: DrawerItem.uplinePayments,
                iconColor: const Color(0xFF00BCD4),
              ),
              _buildNavItem(
                icon: Icons.trending_up_rounded,
                label: 'Daily ROI Payments',
                item: DrawerItem.dailyRoiPayments,
                iconColor: const Color(0xFFFFB300),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'TRANSACTIONS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textTertiary,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              _buildNavItem(
                icon: Icons.receipt_long_outlined,
                label: 'Mining Transactions',
                item: DrawerItem.miningTransactions,
                iconColor: const Color(0xFF795548),
              ),
              _buildNavItem(
                icon: Icons.receipt_outlined,
                label: 'Staking Transactions',
                item: DrawerItem.stakingTransactions,
                iconColor: const Color(0xFF546E7A),
              ),
              _buildWalletInfoCard(),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ── Expandable Completed Hash tile (shared by drawer & sidenav) ────

  Widget _buildExpandableNavItem({
    required IconData icon,
    required String label,
    required Color iconColor,
    required bool isParentSelected,
  }) {
    final color = iconColor;
    return Column(
      children: [
        // Parent tile
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          child: Material(
            color: isParentSelected ? AppColors.primaryFaint : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                setState(() {
                  _isCompletedHashExpanded = !_isCompletedHashExpanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, size: 18, color: color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isParentSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isParentSelected ? AppColors.primary : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: _isCompletedHashExpanded ? 0.25 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: isParentSelected ? AppColors.primary : AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Sub-items
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: _buildPackageSubItems(),
          crossFadeState: _isCompletedHashExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 250),
        ),
      ],
    );
  }

  Widget _buildPackageSubItems() {
    final packages = PackageConstants.allPackages;

    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 12, bottom: 4),
      child: Column(
        children: packages.map((name) {
          final isSelected = _selectedItem == DrawerItem.completedHash &&
              _selectedPackageName == name;
          final planColor = _colorForPlan(name);
          final planIcon = _iconForPlan(name);

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 1),
            child: Material(
              color: isSelected ? AppColors.primaryFaint : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => _onPackageSelected(name),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: planColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(planIcon, size: 15, color: planColor),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Regular nav item ────────────────────────────────────────────────

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required DrawerItem item,
    Color? iconColor,
  }) {
    final isSelected = _selectedItem == item;
    final color = iconColor ?? (isSelected ? AppColors.primary : AppColors.textSecondary);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: isSelected ? AppColors.primaryFaint : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _onItemSelected(item),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color:
                          isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Drawer (Mobile) ─────────────────────────────────────────────────

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBrandHeader(),
              Container(height: 1, color: AppColors.border),
              const SizedBox(height: 8),
              _buildDrawerTile(
                icon: Icons.people_rounded,
                label: 'Users',
                item: DrawerItem.users,
                iconColor: const Color(0xFF2196F3),
              ),
              // ── Expandable Completed Hash ──
              _buildExpandableNavItem(
                icon: Icons.verified_rounded,
                label: 'Completed Hash',
                iconColor: const Color(0xFF4CAF50),
                isParentSelected: _selectedItem == DrawerItem.completedHash,
              ),
              _buildDrawerTile(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Wallet Overview',
                item: DrawerItem.walletOverview,
                iconColor: AppColors.primary,
              ),
              _buildDrawerTile(
                icon: Icons.bar_chart_rounded,
                label: 'Minings',
                item: DrawerItem.minings,
                iconColor: const Color(0xFFFF9800),
              ),
              _buildDrawerTile(
                icon: Icons.stacked_line_chart_rounded,
                label: 'Stakings',
                item: DrawerItem.stakings,
                iconColor: const Color(0xFF9C27B0),
              ),
              _buildDrawerTile(
                icon: Icons.settings_outlined,
                label: 'Staking Settings',
                item: DrawerItem.stakingSettings,
                iconColor: const Color(0xFF607D8B),
              ),
              _buildDrawerTile(
                icon: Icons.people_outline_rounded,
                label: 'Upline Payments',
                item: DrawerItem.uplinePayments,
                iconColor: const Color(0xFF00BCD4),
              ),
              _buildDrawerTile(
                icon: Icons.trending_up_rounded,
                label: 'Daily ROI Payments',
                item: DrawerItem.dailyRoiPayments,
                iconColor: const Color(0xFFFFB300),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'TRANSACTIONS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textTertiary,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              _buildDrawerTile(
                icon: Icons.receipt_long_outlined,
                label: 'Mining Transactions',
                item: DrawerItem.miningTransactions,
                iconColor: const Color(0xFF795548),
              ),
              _buildDrawerTile(
                icon: Icons.receipt_outlined,
                label: 'Staking Transactions',
                item: DrawerItem.stakingTransactions,
                iconColor: const Color(0xFF546E7A),
              ),
              _buildWalletInfoCard(),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerTile({
    required IconData icon,
    required String label,
    required DrawerItem item,
    Color? iconColor,
  }) {
    final isSelected = _selectedItem == item;
    final color = iconColor ?? (isSelected ? AppColors.primary : AppColors.textSecondary);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: isSelected ? AppColors.primaryFaint : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _onItemSelected(item),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Shared Components ───────────────────────────────────────────────

  Widget _buildBrandHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.admin_panel_settings_rounded,
              size: 24,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Quanthex Admin',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletInfoCard() {
    return Consumer<WalletController>(
      builder: (context, walletCtr, _) {
        if (walletCtr.currentWallet == null) return const SizedBox();
        final address = walletCtr.currentWallet!.walletAddress ?? '';
        final shortAddr = address.length > 12
            ? '${address.substring(0, 6)}...${address.substring(address.length - 4)}'
            : address;
        return Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.primaryFaint,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.primarySurface),
          ),
          child: Row(
            children: [
              const Icon(Icons.account_balance_wallet_outlined,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  shortAddr,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    switch (_selectedItem) {
      case DrawerItem.users:
        return const UsersView();
      case DrawerItem.completedHash:
        return CompletedHashUsersPage(
          key: ValueKey('completed_hash_${_selectedPackageName ?? 'all'}'),
          packageName: _selectedPackageName,
        );
      case DrawerItem.walletOverview:
        return const HomeView();
      case DrawerItem.minings:
        return const MiningsView();
      case DrawerItem.stakings:
        return const StakingsView();
      case DrawerItem.stakingSettings:
        return const StakingSettingsView();
      case DrawerItem.uplinePayments:
        return const UplinePaymentsView();
      case DrawerItem.dailyRoiPayments:
        return const DailyRoiPaymentsView();
      case DrawerItem.miningTransactions:
        return const MiningTransactionsView();
      case DrawerItem.stakingTransactions:
        return const StakingTransactionsView();
    }
  }
}
