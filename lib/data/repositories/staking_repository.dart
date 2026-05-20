import 'package:quanthex_admin/data/datasources/staking_remote_datasource.dart';
import '../domain/models/staking_record_model.dart';
import '../domain/models/staking_settings_model.dart';
import '../domain/models/staking_payment_model.dart';
import '../domain/models/daily_roi_settings_model.dart';
import '../domain/models/daily_roi_payment_model.dart';
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

  Future<PaginatedResponse<StakingPaymentModel>> getStakingPayments({
    required int offset,
    required int limit,
    String? status,
    String? planName,
    String? email,
    int? startDate,
    int? endDate,
  }) {
    return _remoteDataSource.getStakingPayments(
      offset: offset,
      limit: limit,
      status: status,
      planName: planName,
      email: email,
      startDate: startDate,
      endDate: endDate,
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

  Future<DailyRoiSettingsModel?> getDailyRoiSettings() {
    return _remoteDataSource.getDailyRoiSettings();
  }

  Future<DailyRoiSettingsModel> updateDailyRoiSettings({
    double? dailyRoiPercentage,
    bool? isActive,
  }) {
    return _remoteDataSource.updateDailyRoiSettings(
      dailyRoiPercentage: dailyRoiPercentage,
      isActive: isActive,
    );
  }

  Future<Map<String, dynamic>> getDailyRoiEligible() {
    return _remoteDataSource.getDailyRoiEligible();
  }

  Future<Map<String, dynamic>> payDailyRoi(
    String stakingId, {
    required String txData,
    required int chainId,
  }) {
    return _remoteDataSource.payDailyRoi(stakingId, txData: txData, chainId: chainId);
  }

  Future<Map<String, dynamic>> payAllDailyRoi(List<Map<String, dynamic>> items) {
    return _remoteDataSource.payAllDailyRoi(items);
  }

  Future<PaginatedResponse<DailyRoiPaymentModel>> getDailyRoiPayments({
    required int offset,
    required int limit,
    String? status,
    String? email,
    String? paymentDate,
  }) {
    return _remoteDataSource.getDailyRoiPayments(
      offset: offset,
      limit: limit,
      status: status,
      email: email,
      paymentDate: paymentDate,
    );
  }
}
