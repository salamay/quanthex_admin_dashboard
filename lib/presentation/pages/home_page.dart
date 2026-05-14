import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:quanthex_admin/core/router/app_router.dart';
import 'package:quanthex_admin/core/theme/app_colors.dart';
import 'package:quanthex_admin/presentation/providers/wallet_controller.dart';
import 'package:quanthex_admin/presentation/providers/auth_provider.dart';
import 'package:quanthex_admin/presentation/pages/home/home_view.dart';
import 'package:quanthex_admin/presentation/pages/mining/minings_page.dart';
import 'package:quanthex_admin/presentation/pages/staking/stakings_view.dart';
import 'package:quanthex_admin/presentation/pages/staking/staking_settings_page.dart';
import 'package:quanthex_admin/presentation/pages/staking/upline_payments_view.dart';
import 'package:quanthex_admin/presentation/pages/mining/mining_transactions_view.dart';
import 'package:quanthex_admin/presentation/pages/staking/staking_transactions_view.dart';

enum DrawerItem { walletOverview, minings, stakings, stakingSettings, uplinePayments, miningTransactions, stakingTransactions }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DrawerItem _selectedItem = DrawerItem.walletOverview;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String get _title {
    switch (_selectedItem) {
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
      case DrawerItem.miningTransactions:
        return 'Mining Transactions';
      case DrawerItem.stakingTransactions:
        return 'Staking Transactions';
    }
  }

  void _onItemSelected(DrawerItem item) {
    setState(() => _selectedItem = item);
    // Close drawer on mobile
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
          // Permanent side navigation
          _buildSideNav(),
          Container(width: 1, color: AppColors.border),
          // Main content area
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
        child: Column(
          children: [
            _buildBrandHeader(),
            Container(height: 1, color: AppColors.border),
            const SizedBox(height: 8),
            _buildNavItem(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Wallet Overview',
              item: DrawerItem.walletOverview,
            ),
            _buildNavItem(
              icon: Icons.bar_chart_rounded,
              label: 'Minings',
              item: DrawerItem.minings,
            ),
            _buildNavItem(
              icon: Icons.stacked_line_chart_rounded,
              label: 'Stakings',
              item: DrawerItem.stakings,
            ),
            _buildNavItem(
              icon: Icons.settings_outlined,
              label: 'Staking Settings',
              item: DrawerItem.stakingSettings,
            ),
            _buildNavItem(
              icon: Icons.people_outline_rounded,
              label: 'Upline Payments',
              item: DrawerItem.uplinePayments,
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
            ),
            _buildNavItem(
              icon: Icons.receipt_outlined,
              label: 'Staking Transactions',
              item: DrawerItem.stakingTransactions,
            ),
            const Spacer(),
            _buildWalletInfoCard(),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required DrawerItem item,
  }) {
    final isSelected = _selectedItem == item;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: isSelected ? AppColors.primaryFaint : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => _onItemSelected(item),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(icon, size: 20,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color:
                        isSelected ? AppColors.primary : AppColors.textPrimary,
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
        child: Column(
          children: [
            _buildBrandHeader(),
            Container(height: 1, color: AppColors.border),
            const SizedBox(height: 8),
            _buildDrawerTile(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Wallet Overview',
              item: DrawerItem.walletOverview,
            ),
            _buildDrawerTile(
              icon: Icons.bar_chart_rounded,
              label: 'Minings',
              item: DrawerItem.minings,
            ),
            _buildDrawerTile(
              icon: Icons.stacked_line_chart_rounded,
              label: 'Stakings',
              item: DrawerItem.stakings,
            ),
            _buildDrawerTile(
              icon: Icons.settings_outlined,
              label: 'Staking Settings',
              item: DrawerItem.stakingSettings,
            ),
            _buildDrawerTile(
              icon: Icons.people_outline_rounded,
              label: 'Upline Payments',
              item: DrawerItem.uplinePayments,
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
            ),
            _buildDrawerTile(
              icon: Icons.receipt_outlined,
              label: 'Staking Transactions',
              item: DrawerItem.stakingTransactions,
            ),
            const Spacer(),
            _buildWalletInfoCard(),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerTile({
    required IconData icon,
    required String label,
    required DrawerItem item,
  }) {
    final isSelected = _selectedItem == item;
    return ListTile(
      leading: Icon(icon, size: 22,
          color: isSelected ? AppColors.primary : AppColors.textSecondary),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
        ),
      ),
      selected: isSelected,
      selectedTileColor: AppColors.primaryFaint,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      onTap: () => _onItemSelected(item),
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
      case DrawerItem.miningTransactions:
        return const MiningTransactionsView();
      case DrawerItem.stakingTransactions:
        return const StakingTransactionsView();
    }
  }
}
