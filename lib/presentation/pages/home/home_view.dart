import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:skeletonizer/skeletonizer.dart';
import '../../../core/constants/network_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/domain/entities/supported_assets.dart';
import '../../../data/domain/entities/wallet_model.dart';
import '../../../data/domain/models/balance/CoinBalance.dart';
import '../../../data/repositories/asset_repository.dart';
import '../../../data/services/assets/asset_service.dart';
import '../../../data/utils/logger.dart';

import '../../../data/utils/my_currency_utils.dart';
import '../../providers/asset_controllers.dart';
import '../../providers/balance_controller.dart';
import '../../providers/wallet_controller.dart';
import '../../widgets/global/error_modal.dart';
import 'components/asset_item.dart';


class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with WidgetsBindingObserver {

  ValueNotifier<bool> _loadingNotifier = ValueNotifier(true);
  ValueNotifier<bool> _errorNotifier = ValueNotifier(false);
  late AssetController assetController;
  late WalletController walletController;
  late BalanceController balanceController;

  AssetService assetService = AssetService.getInstance();
  late Timer _balanceTimer;

  void _startBalanceTimer() {
    _balanceTimer = Timer.periodic(Duration(seconds: 60), (timer) async {
      refreshData();
    });
  }

  void _stopBalanceTimer() {
    _balanceTimer.cancel();
  }

  Future<void> getData() async {
    try {
      if (!mounted) {
        return;
      }
      _loadingNotifier.value = true;
      String walletAddress = walletController.currentWallet?.walletAddress ?? "";
      bool isCacheEmpty = await AssetRepo.getInstance().isCacheAssetEmpty(walletAddress);
      bool isNew = isCacheEmpty ? true : false;
      logger("isNew: $isNew", runtimeType.toString());
      List<SupportedCoin> assets = await assetController.getAllAssets(isNew: isNew, assetService: assetService, walletController: walletController);
      logger("Assets ${assets.length}", runtimeType.toString());
      await assetController.getAssetsQuotes(balanceController: balanceController, assets: assets);
      await getTokenBalances(context: context,shouldIndicate: true);
      if (isNew) {
        await AssetRepo.getInstance().saveAssets(walletAddress: walletAddress, newTokens: assets);
      }
      _loadingNotifier.value = false;
      _errorNotifier.value = false;
      _startBalanceTimer();
    } catch (e) {
      logger(e.toString(), runtimeType.toString());
      _errorNotifier.value = true;
      _loadingNotifier.value = false;
    }
  }



  Future<void> refreshData() async {
    List<SupportedCoin> assets = await assetController.assets;
    logger("Assets ${assets.length}", runtimeType.toString());
    await assetController.getAssetsQuotes(balanceController: balanceController, assets: assets);
    await getTokenBalances(context: context,shouldIndicate: false);
  }

  Future<void> reload() async {
    try {
      balanceController.clear();
      _stopBalanceTimer();
      await getData();
      _startBalanceTimer();
    } catch (e) {
      logger("Error reloading data: $e", runtimeType.toString());
      logger("Error getting data: $e", runtimeType.toString());
      _errorNotifier.value = true;
      _loadingNotifier.value = false;
      return;
    }
  }

  @override
  void initState() {
    _balanceTimer = Timer.periodic(Duration(seconds: 60), (timer) async {});
    assetController = Provider.of<AssetController>(context, listen: false);
    balanceController = Provider.of<BalanceController>(context, listen: false);
    walletController = Provider.of<WalletController>(context, listen: false);
    WidgetsBinding.instance.addObserver(this);
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      getData();
    });
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopBalanceTimer();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    logger("AppLifecycleState: $state", runtimeType.toString());
    if (state == AppLifecycleState.resumed) {
      _startBalanceTimer();
    } else if (state == AppLifecycleState.inactive) {
      _stopBalanceTimer();
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 800;

    return Container(
      color: AppColors.background,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isWide ? 720 : double.infinity),
          child: RefreshIndicator(
            onRefresh: () async {
              reload();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 24 : 8.sp,
                vertical: isWide ? 24 : 0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: isWide ? 8 : 20.sp),

                  // Header logo
                  Row(
                    mainAxisAlignment: isWide ? MainAxisAlignment.center : MainAxisAlignment.start,
                    children: [
                      Image.asset(
                        "assets/images/logo.png",
                        height: isWide ? 50 : 50.h,
                        width: isWide ? 50 : 50.w,
                      ),
                      const SizedBox(width: 2),
                      Image.asset(
                        "assets/images/quanthex_2.png",
                        height: isWide ? 80 : 80.h,
                        width: isWide ? 80 : 80.w,
                      ),
                    ],
                  ),

                  SizedBox(height: isWide ? 20 : 15.sp),

                  // Wallet address chip (wide screen only)
                  if (isWide)
                    Consumer<WalletController>(
                      builder: (context, walletCtr, _) {
                        if (walletCtr.currentWallet == null) return const SizedBox();
                        final address = walletCtr.currentWallet!.walletAddress ?? '';
                        final shortAddr = address.length > 12
                            ? '${address.substring(0, 6)}...${address.substring(address.length - 4)}'
                            : address;
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryFaint,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.primarySurface),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.account_balance_wallet_outlined,
                                  size: 16, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Text(
                                shortAddr,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                  if (isWide) const SizedBox(height: 24),

                  // Portfolio Value
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Portfolio Value',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: isWide ? 14 : 14.sp,
                          fontFamily: 'Satoshi',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: isWide ? 8 : 8),
                      Consumer<BalanceController>(
                        builder: (context, balanceCtr, child) {
                          return GestureDetector(
                            onTap: () {
                              balanceCtr.toggleHideBalance();
                            },
                            child: Icon(
                              !balanceCtr.hideBalance
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: isWide ? 18 : 18.sp,
                              color: AppColors.textSecondary,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: isWide ? 10 : 10.sp),

                  // Balance amount
                  Consumer<BalanceController>(
                    builder: (context, balanceCtr, child) {
                      return Skeletonizer(
                        ignoreContainers: false,
                        enabled: balanceCtr.balanceLoading,
                        effect: ShimmerEffect(
                          duration: const Duration(milliseconds: 1000),
                          baseColor: Colors.grey.withOpacity(0.4),
                          highlightColor: Colors.white54,
                        ),
                        child: AutoSizeText(
                          balanceCtr.hideBalance
                              ? '****'
                              : MyCurrencyUtils.formatCurrency(balanceCtr.overallBalance),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: isWide ? 36 : 32.sp,
                            fontFamily: 'Satoshi',
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                        ),
                      );
                    },
                  ),
                  SizedBox(height: isWide ? 8 : 8.sp),

                  // Placeholder for future P&L row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [],
                  ),

                  SizedBox(height: isWide ? 16 : 10.sp),

                  // My Assets header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'My Assets',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: isWide ? 18 : 18.sp,
                          fontFamily: 'Satoshi',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isWide ? 8 : 5.sp),

                  // Assets list
                  ValueListenableBuilder(
                    valueListenable: _errorNotifier,
                    builder: (context, isError, _) {
                      return !isError
                          ? ValueListenableBuilder(
                              valueListenable: _loadingNotifier,
                              builder: (context, loading, _) {
                                return Skeletonizer(
                                  ignoreContainers: false,
                                  enabled: loading,
                                  effect: ShimmerEffect(
                                    duration: const Duration(milliseconds: 1000),
                                    baseColor: Colors.grey.withOpacity(0.4),
                                    highlightColor: Colors.white54,
                                  ),
                                  child: Consumer<AssetController>(
                                    builder: (context, assetCtr, child) {
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: assetCtr.assets.map((e) {
                                          return AssetItem(coin: e);
                                        }).toList(),
                                      );
                                    },
                                  ),
                                );
                              },
                            )
                          : ErrorModal(
                              callBack: () {
                                _errorNotifier.value = false;
                                _loadingNotifier.value = true;
                                reload();
                              },
                            );
                    },
                  ),
                  SizedBox(height: isWide ? 16 : 10.sp),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> getTokenBalances({required BuildContext context, required bool shouldIndicate}) async {
    List<SupportedCoin> assets = assetController.assets;
    List<SupportedCoin> tokens = assets.where((element) => element.coinType == CoinType.TOKEN).toList();
    List<SupportedCoin> nativeTokens = assets.where((element) => element.coinType == CoinType.NATIVE_TOKEN || element.coinType == CoinType.WRAPPED_TOKEN).toList();
    Map<String, CoinBalance> results = await balanceController.getTokenBalance(tokens, shouldIndicate);
    assetController.populateAssetsByBalanceInFiat(results);
    await Future.wait(
      nativeTokens.map((e) async {
        int old = DateTime.now().second;
        await Future.delayed(const Duration(milliseconds: 200), () async {});
        int newTime = DateTime.now().second;
        logger("Time taken: ${newTime - old}", runtimeType.toString());
        CoinBalance? nativeBalance = await balanceController.getNativeCoinBalance(asset: e);
        assetController.populateAssetsByBalanceInFiatNativeTokens(e.symbol, nativeBalance ?? CoinBalance(balanceInCrypto: 0, balanceInFiat: 0));
        results[e.symbol] = nativeBalance ?? CoinBalance(balanceInCrypto: 0, balanceInFiat: 0);
      }),
    );
    assetController.sortAssetsByBalanceInFiat();
    balanceController.overallBalance = 0;
    balanceController.calculateTotalBalance(results);
  }

  List<Color> _generateGradientFromAddress(String address) {
    final colors = [
      [Colors.blue, Colors.purple],
      [Colors.purple, Colors.pink],
      [Colors.red, Colors.orange],
      [Colors.orange, Colors.yellow],
      [Colors.green, Colors.teal],
      [Colors.teal, Colors.blue],
      [Colors.pink, Colors.red],
      [Colors.yellow, Colors.green],
    ];
    int hash = address.hashCode;
    int index = hash.abs() % colors.length;
    return colors[index];
  }

}
