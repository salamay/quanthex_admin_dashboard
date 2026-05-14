import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quanthex_admin/data/domain/entities/supported_assets.dart';
import 'package:quanthex_admin/data/domain/models/mining_record_model.dart';
import 'package:quanthex_admin/data/domain/models/staking_record_model.dart';
import 'package:quanthex_admin/data/domain/models/mining_payment_model.dart';
import 'package:quanthex_admin/data/domain/models/staking_payment_model.dart';
import 'package:quanthex_admin/data/domain/models/upline_payment_model.dart';
import 'package:quanthex_admin/presentation/pages/splash_page.dart';
import 'package:quanthex_admin/presentation/pages/auth/sign_in_page.dart';
import 'package:quanthex_admin/presentation/pages/wallets/import_wallet_page.dart';
import 'package:quanthex_admin/presentation/pages/home_page.dart';
import 'package:quanthex_admin/presentation/pages/mining/mining_detail_page.dart';
import 'package:quanthex_admin/presentation/pages/mining/mining_transaction_detail_page.dart';
import 'package:quanthex_admin/presentation/pages/staking/staking_detail_page.dart';
import 'package:quanthex_admin/presentation/pages/staking/staking_transaction_detail_page.dart';
import 'package:quanthex_admin/presentation/pages/send/send_token_view.dart';
import 'package:quanthex_admin/presentation/pages/staking/upline_payment_detail_page.dart';

/// Centralized route path constants for type-safe navigation.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String signIn = '/sign-in';
  static const String importWallet = '/import-wallet';
  static const String home = '/home';
  static const String miningDetail = '/mining-detail';
  static const String stakingDetail = '/staking-detail';
  static const String sendToken = '/send-token';
  static const String uplinePaymentDetail = '/upline-payment-detail';
  static const String miningPaymentDetail = '/mining-payment-detail';
  static const String stakingPaymentDetail = '/staking-payment-detail';
}

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.signIn,
        name: 'signIn',
        builder: (context, state) => const SignInPage(),
      ),
      GoRoute(
        path: AppRoutes.importWallet,
        name: 'importWallet',
        builder: (context, state) => const ImportWalletPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.miningDetail,
        name: 'miningDetail',
        builder: (context, state) {
          final record = state.extra as MiningRecordModel;
          return MiningDetailPage(record: record);
        },
      ),
      GoRoute(
        path: AppRoutes.stakingDetail,
        name: 'stakingDetail',
        builder: (context, state) {
          final record = state.extra as StakingRecordModel;
          return StakingDetailPage(record: record);
        },
      ),
      GoRoute(
        path: AppRoutes.sendToken,
        name: 'sendToken',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          final coin = data['coin'] as SupportedCoin;
          final miningRecord = data['miningRecord'] as MiningRecordModel?;
          final stakingRecord = data['stakingRecord'] as StakingRecordModel?;
          final uplinePayment = data['uplinePayment'] as UplinePaymentModel?;
          return SendTokenView(
            coin: coin,
            miningRecord: miningRecord,
            stakingRecord: stakingRecord,
            uplinePayment: uplinePayment,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.uplinePaymentDetail,
        name: 'uplinePaymentDetail',
        builder: (context, state) {
          final payment = state.extra as UplinePaymentModel;
          return UplinePaymentDetailPage(payment: payment);
        },
      ),
      GoRoute(
        path: AppRoutes.miningPaymentDetail,
        name: 'miningPaymentDetail',
        builder: (context, state) {
          final payment = state.extra as MiningPaymentModel;
          return MiningTransactionDetailPage(payment: payment);
        },
      ),
      GoRoute(
        path: AppRoutes.stakingPaymentDetail,
        name: 'stakingPaymentDetail',
        builder: (context, state) {
          final payment = state.extra as StakingPaymentModel;
          return StakingTransactionDetailPage(payment: payment);
        },
      ),
    ],
  );
}
