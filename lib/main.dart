import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
import 'package:quanthex_admin/core/di/service_locator.dart';
import 'package:quanthex_admin/core/router/app_router.dart';
import 'package:quanthex_admin/core/theme/app_colors.dart';
import 'package:quanthex_admin/presentation/widgets/loading_overlay/loading.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ServiceLocator.instance.init();

  runApp(const QuanthexAdminApp());
}

class QuanthexAdminApp extends StatelessWidget {
  const QuanthexAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) => ServiceLocator.instance.createAuthProvider(),
            ),
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
              routerConfig: AppRouter.router,
            ),
          ),
        );
      },
    );
  }
}
