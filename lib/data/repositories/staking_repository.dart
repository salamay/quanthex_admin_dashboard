import 'package:quanthex_admin/data/datasources/staking_remote_datasource.dart';
import '../domain/models/staking_record_model.dart';
import '../domain/models/staking_settings_model.dart';
import '../domain/models/upline_payment_model.dart';
import '../domain/models/paginated_response.dart';

class StakingRepository {
  final StakingRemoteDataSource _remoteDataSource;

  StakingRepository(this._remoteDataSource);

  Future<PaginatedResponse<StakingRecordModel>> getAllStakings({
    required int offset,
    required int limit,
    String? planName,
    String? status,
    int? startDate,
    int? endDate,
  }) {
    return _remoteDataSource.getAllStakings(
      offset: offset,
      limit: limit,
      planName: planName,
      status: status,
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<List<StakingSettingsModel>> getStakingSettings() {
    return _remoteDataSource.getStakingSettings();
  }

  Future<StakingSettingsModel> updateStakingSettings({
    required String ssId,
    double? rewardPercentage,
    int? referralsPerCycle,
    bool? isActive,
  }) {
    return _remoteDataSource.updateStakingSettings(
      ssId: ssId,
      rewardPercentage: rewardPercentage,
      referralsPerCycle: referralsPerCycle,
      isActive: isActive,
    );
  }

  Future<PaginatedResponse<UplinePaymentModel>> getUplinePayments({
    required int offset,
    required int limit,
    String? status,
    String? planName,
  }) {
    return _remoteDataSource.getUplinePayments(
      offset: offset,
      limit: limit,
      status: status,
      planName: planName,
    );
  }

  Future<Map<String, dynamic>> submitUplinePayment({
    required String supId,
    required int chainId,
    String? txData,
  }) {
    return _remoteDataSource.submitUplinePayment(
      supId: supId,
      chainId: chainId,
      txData: txData,
    );
  }
}
