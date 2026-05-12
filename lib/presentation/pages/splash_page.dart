import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:quanthex_admin/core/router/app_router.dart';
import 'package:quanthex_admin/core/theme/app_colors.dart';
import 'package:quanthex_admin/presentation/providers/wallet_controller.dart';
import 'package:quanthex_admin/presentation/providers/auth_provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final authProvider = context.read<AuthProvider>();
    final walletController = context.read<WalletController>();

    // Load auth and wallets in parallel
    await Future.wait([
      authProvider.checkAuth(),
      walletController.loadWallets(),
    ]);

    if (!mounted) return;

    // Small delay so splash is visible briefly
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    String route;
    if (authProvider.status != AuthStatus.authenticated) {
      route = AppRoutes.signIn;
    } else if (walletController.wallets.isEmpty) {
      route = AppRoutes.importWallet;
    } else {
      route = AppRoutes.home;
    }

    context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.admin_panel_settings_rounded,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Quanthex Admin',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
