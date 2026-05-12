import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:quanthex_admin/core/router/app_router.dart';
import 'package:quanthex_admin/core/theme/app_colors.dart';
import 'package:quanthex_admin/presentation/providers/wallet_controller.dart';
import 'package:quanthex_admin/data/services/wallets/wallet_services.dart';

class ImportWalletPage extends StatefulWidget {
  const ImportWalletPage({super.key});

  @override
  State<ImportWalletPage> createState() => _ImportWalletPageState();
}

class _ImportWalletPageState extends State<ImportWalletPage> {
  final _mnemonicController = TextEditingController();
  bool _isImporting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _mnemonicController.dispose();
    super.dispose();
  }

  Future<void> _handleImport() async {
    final mnemonic = _mnemonicController.text.trim();

    if (mnemonic.isEmpty) {
      setState(() => _errorMessage = 'Please enter your mnemonic phrase');
      return;
    }

    final words = mnemonic.split(RegExp(r'\s+'));
    if (words.length != 12 && words.length != 24) {
      setState(() => _errorMessage = 'Mnemonic must be 12 or 24 words');
      return;
    }

    setState(() {
      _isImporting = true;
      _errorMessage = null;
    });

    try {
      final walletService = WalletServices.getInstance();
      final wallet = await walletService.importFromMnemonic(mnemonic);

      if (!mounted) return;

      final walletController = context.read<WalletController>();
      await walletController.addWallet(wallet);
      walletController.setCurrentWallet(wallet);

      if (!mounted) return;

      context.go(AppRoutes.home);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isImporting = false;
        _errorMessage = 'Failed to import wallet. Please check your mnemonic phrase.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Icon
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 40,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  const Text(
                    'Import Wallet',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Enter your mnemonic phrase to import your admin wallet. This wallet will be used for paying users.',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Info card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryFaint,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.primarySurface),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, size: 18, color: AppColors.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Your mnemonic is stored securely on this device and never sent to any server.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primary.withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Label
                  const Text(
                    'Mnemonic Phrase',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Mnemonic input
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _errorMessage != null ? AppColors.error : AppColors.border,
                      ),
                    ),
                    child: TextField(
                      controller: _mnemonicController,
                      maxLines: 4,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textPrimary,
                        height: 1.6,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter your 12 or 24 word mnemonic phrase separated by spaces...',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: AppColors.textTertiary,
                        ),
                        contentPadding: const EdgeInsets.all(14),
                        border: InputBorder.none,
                      ),
                      onChanged: (_) {
                        if (_errorMessage != null) {
                          setState(() => _errorMessage = null);
                        }
                      },
                    ),
                  ),

                  // Error message
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.error,
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Import button
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isImporting ? null : _handleImport,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.primaryLight,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Import Wallet',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

          // Loader overlay
          if (_isImporting)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Importing Wallet...',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Deriving keys from mnemonic',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
