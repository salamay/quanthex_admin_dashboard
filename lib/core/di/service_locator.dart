import 'package:quanthex_admin/core/network/api_client.dart';
import 'package:quanthex_admin/presentation/providers/wallet_controller.dart';
import 'package:quanthex_admin/data/datasources/auth_remote_datasource.dart';
import 'package:quanthex_admin/data/datasources/mining_remote_datasource.dart';
import 'package:quanthex_admin/data/datasources/staking_remote_datasource.dart';
import 'package:quanthex_admin/data/local/token_storage.dart';
import 'package:quanthex_admin/data/repositories/auth_repository.dart';
import 'package:quanthex_admin/data/repositories/mining_repository.dart';
import 'package:quanthex_admin/data/repositories/staking_repository.dart';
import 'package:quanthex_admin/data/repositories/secure_storage.dart';
import 'package:quanthex_admin/presentation/providers/auth_provider.dart';
import 'package:quanthex_admin/presentation/providers/mining_provider.dart';
import 'package:quanthex_admin/presentation/providers/staking_provider.dart';
import 'package:quanthex_admin/presentation/providers/staking_settings_provider.dart';
import 'package:quanthex_admin/presentation/providers/upline_payments_provider.dart';
import 'package:quanthex_admin/presentation/providers/mining_payments_provider.dart';
import 'package:quanthex_admin/presentation/providers/staking_payments_provider.dart';

import '../../presentation/providers/asset_controllers.dart';
import '../../presentation/providers/balance_controller.dart';

class ServiceLocator {
  ServiceLocator._();

  static final ServiceLocator instance = ServiceLocator._();

  late final ApiClient apiClient;
  late final TokenStorage tokenStorage;

  // Auth
  late final AuthRemoteDataSource authRemoteDataSource;
  late final AuthRepository authRepository;

  // Mining
  late final MiningRemoteDataSource miningRemoteDataSource;
  late final MiningRepository miningRepository;

  // Staking
  late final StakingRemoteDataSource stakingRemoteDataSource;
  late final StakingRepository stakingRepository;

  late final SecureStorage secureStorage;

  void init() {
    apiClient = ApiClient();
    tokenStorage = TokenStorage();
    secureStorage = SecureStorage.getInstance();

    authRemoteDataSource = AuthRemoteDataSource(apiClient);
    authRepository = AuthRepository(authRemoteDataSource, tokenStorage, apiClient);

    miningRemoteDataSource = MiningRemoteDataSource(apiClient);
    miningRepository = MiningRepository(miningRemoteDataSource);

    stakingRemoteDataSource = StakingRemoteDataSource(apiClient);
    stakingRepository = StakingRepository(stakingRemoteDataSource);
  }

  AuthProvider createAuthProvider() {
    return AuthProvider(authRepository);
  }

  MiningProvider createMiningProvider() {
    return MiningProvider(miningRepository);
  }

  StakingProvider createStakingProvider() {
    return StakingProvider(stakingRepository);
  }

  StakingSettingsProvider createStakingSettingsProvider() {
    return StakingSettingsProvider(stakingRepository);
  }

  UplinePaymentsProvider createUplinePaymentsProvider() {
    return UplinePaymentsProvider(stakingRepository);
  }

  AssetController createAssetController() {
    return AssetController(apiClient);
  }
  BalanceController createBalanceController() {
    return BalanceController(apiClient);
  }
  WalletController createWalletController() {
    return WalletController(secureStorage);
  }

  MiningPaymentsProvider createMiningPaymentsProvider() {
    return MiningPaymentsProvider(miningRepository);
  }

  StakingPaymentsProvider createStakingPaymentsProvider() {
    return StakingPaymentsProvider(stakingRepository);
  }
}
