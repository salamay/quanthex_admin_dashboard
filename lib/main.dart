import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
import 'package:quanthex_admin/core/di/service_locator.dart';
import 'package:quanthex_admin/core/router/app_router.dart';
import 'package:quanthex_admin/core/theme/app_colors.dart';
import 'package:quanthex_admin/presentation/providers/auth_provider.dart';
import 'package:quanthex_admin/presentation/widgets/loading_overlay/loading.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ServiceLocator.instance.init();

  runApp(const QuanthexAdminApp());
}

class QuanthexAdminApp extends StatefulWidget {
  const QuanthexAdminApp({super.key});

  @override
  State<QuanthexAdminApp> createState() => _QuanthexAdminAppState();
}

class _QuanthexAdminAppState extends State<QuanthexAdminApp> {
  late final AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    _authProvider = ServiceLocator.instance.createAuthProvider();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: _authProvider),
            ChangeNotifierProvider(
              create: (_) => ServiceLocator.instance.createMiningProvider(),
            ),
            ChangeNotifierProvider(
              create: (_) => ServiceLocator.instance.createAssetController(),
            ),
            ChangeNotifierProvider(
              create: (_) => ServiceLocator.instance.createBalanceController(),
            ),
            ChangeNotifierProvider(
              create: (_) => ServiceLocator.instance.createWalletController(),
            ),
            ChangeNotifierProvider(
              create: (_) => ServiceLocator.instance.createStakingProvider(),
            ),
            ChangeNotifierProvider(
              create: (_) => ServiceLocator.instance.createStakingSettingsProvider(),
            ),
            ChangeNotifierProvider(
              create: (_) => ServiceLocator.instance.createUplinePaymentsProvider(),
            ),
            ChangeNotifierProvider(
              create: (_) => ServiceLocator.instance.createMiningPaymentsProvider(),
            ),
            ChangeNotifierProvider(
              create: (_) => ServiceLocator.instance.createStakingPaymentsProvider(),
            ),
            ChangeNotifierProvider(
              create: (_) => ServiceLocator.instance.createDailyRoiProvider(),
            ),
            ChangeNotifierProvider(
              create: (_) => ServiceLocator.instance.createUsersProvider(),
            ),
          ],
          child: GlobalLoaderOverlay(
            overlayColor: Colors.transparent,
            overlayWholeScreen: true,
            overlayWidgetBuilder: (context) => Center(child: Loading(size: 30.sp)),
            child: MaterialApp.router(
              title: 'Quanthex Admin',
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: AppColors.primary,
                ),
                scaffoldBackgroundColor: AppColors.background,
                useMaterial3: true,
              ),
              routerConfig: AppRouter.router(_authProvider),
            ),
          ),
        );
      },
    );
  }
}
