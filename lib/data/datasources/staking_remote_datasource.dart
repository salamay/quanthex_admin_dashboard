import 'dart:developer';
import 'package:quanthex_admin/core/network/api_client.dart';
import 'package:quanthex_admin/core/network/api_constants.dart';
import '../domain/models/staking_record_model.dart';
import '../domain/models/staking_settings_model.dart';
import '../domain/models/staking_payment_model.dart';
import '../domain/models/daily_roi_settings_model.dart';
import '../domain/models/upline_payment_model.dart';
import '../domain/models/paginated_response.dart';

class StakingRemoteDataSource {
  final ApiClient _apiClient;

  StakingRemoteDataSource(this._apiClient);

  Future<PaginatedResponse<StakingRecordModel>> getAllStakings({
    required int offset,
    required int limit,
    String? planName,
    String? status,
    int? startDate,
    int? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'offset': offset.toString(),
        'limit': limit.toString(),
      };

      if (planName != null && planName.isNotEmpty) {
        queryParams['planName'] = planName;
      }
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      if (startDate != null) {
        queryParams['startDate'] = startDate.toString();
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toString();
      }

      final response = await _apiClient.get(
        ApiConstants.stakings,
        queryParams: queryParams,
      );

      if (response == null || response.statusCode != 200) {
        throw Exception('Failed to fetch stakings: ${response?.statusCode}');
      }

      final responseData = response.data;
      final List<dynamic> dataList = responseData['data'] ?? [];
      final int total = responseData['total'] ?? 0;
      final List<dynamic> planNamesList = responseData['planNames'] ?? [];

      final stakings = dataList
          .map((item) => StakingRecordModel.fromJson(item as Map<String, dynamic>))
          .toList();

      final plans = planNamesList.map((e) => e.toString()).toList();

      return PaginatedResponse(data: stakings, total: total, packageNames: plans);
    } catch (e) {
      log('Error fetching stakings: $e');
      rethrow;
    }
  }

  Future<List<StakingSettingsModel>> getStakingSettings() async {
    try {
      final response = await _apiClient.get(ApiConstants.stakingSettings);

      if (response == null || response.statusCode != 200) {
        throw Exception('Failed to fetch staking settings');
      }

      final responseData = response.data;
      final List<dynamic> dataList = responseData is List ? responseData : (responseData['data'] ?? []);

      return dataList
          .map((item) => StakingSettingsModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      log('Error fetching staking settings: $e');
      rethrow;
    }
  }

  Future<StakingSettingsModel> updateStakingSettings({
    required String ssId,
    double? rewardPercentage,
    int? referralsPerCycle,
    bool? isActive,
  }) async {
    try {
      final body = <String, dynamic>{'ss_id': ssId};
      if (rewardPercentage != null) body['ss_reward_percentage'] = rewardPercentage;
      if (referralsPerCycle != null) body['ss_referrals_per_cycle'] = referralsPerCycle;
      if (isActive != null) body['ss_is_active'] = isActive;

      final response = await _apiClient.put(
        ApiConstants.stakingSettings,
        data: body,
      );

      if (response == null || (response.statusCode != 200 && response.statusCode != 201)) {
        throw Exception('Failed to update staking settings');
      }

      final data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : (response.data['data'] as Map<String, dynamic>?) ?? {};

      return StakingSettingsModel.fromJson(data);
    } catch (e) {
      log('Error updating staking settings: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> submitStakingPayment({
    required String stakingId,
    required double amount,
    required int chainId,
    String? txData,
    String? rewardSymbol,
  }) async {
    try {
      final body = <String, dynamic>{
        'staking_id': stakingId,
        'amount': amount,
        'chain_id': chainId,
      };
      if (txData != null) body['tx_data'] = txData;
      if (rewardSymbol != null) body['reward_symbol'] = rewardSymbol;

      final response = await _apiClient.post(
        ApiConstants.submitStakingPayment,
        data: body,
      );

      if (response == null || (response.statusCode != 200 && response.statusCode != 201)) {
        final msg = response?.data?['message'] ?? 'Unknown error';
        throw Exception('Failed to submit staking payment: $msg');
      }

      return response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : (response.data['data'] as Map<String, dynamic>?) ?? {};
    } catch (e) {
      log('Error submitting staking payment: $e');
      rethrow;
    }
  }

  Future<PaginatedResponse<UplinePaymentModel>> getUplinePayments({
    required int offset,
    required int limit,
    String? status,
    String? planName,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'offset': offset.toString(),
        'limit': limit.toString(),
      };
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      if (planName != null && planName.isNotEmpty) {
        queryParams['planName'] = planName;
      }

      final response = await _apiClient.get(
        ApiConstants.stakingUplinePayments,
        queryParams: queryParams,
      );

      if (response == null || response.statusCode != 200) {
        throw Exception('Failed to fetch upline payments: ${response?.statusCode}');
      }

      final responseData = response.data;
      final List<dynamic> dataList = responseData['data'] ?? [];
      final int total = responseData['total'] ?? 0;

      final payments = dataList
          .map((item) => UplinePaymentModel.fromJson(item as Map<String, dynamic>))
          .toList();

      return PaginatedResponse(data: payments, total: total);
    } catch (e) {
      log('Error fetching upline payments: $e');
      rethrow;
    }
  }

  Future<PaginatedResponse<StakingPaymentModel>> getStakingPayments({
    required int offset,
    required int limit,
    String? status,
    String? planName,
    String? email,
    int? startDate,
    int? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'offset': offset.toString(),
        'limit': limit.toString(),
      };
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (planName != null && planName.isNotEmpty) queryParams['planName'] = planName;
      if (email != null && email.isNotEmpty) queryParams['email'] = email;
      if (startDate != null) queryParams['startDate'] = startDate.toString();
      if (endDate != null) queryParams['endDate'] = endDate.toString();

      final response = await _apiClient.get(
        ApiConstants.stakingPayments,
        queryParams: queryParams,
      );

      if (response == null || response.statusCode != 200) {
        throw Exception('Failed to fetch staking payments: ${response?.statusCode}');
      }

      final responseData = response.data;
      final List<dynamic> dataList = responseData['data'] ?? [];
      final int total = responseData['total'] ?? 0;

      final payments = dataList
          .map((item) => StakingPaymentModel.fromJson(item as Map<String, dynamic>))
          .toList();

      return PaginatedResponse(data: payments, total: total);
    } catch (e) {
      log('Error fetching staking payments: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> submitUplinePayment({
    required String supId,
    required int chainId,
    String? txData,
  }) async {
    try {
      final body = <String, dynamic>{
        'sup_id': supId,
        'chain_id': chainId,
      };
      if (txData != null) body['tx_data'] = txData;

      final response = await _apiClient.post(
        ApiConstants.submitUplinePayment,
        data: body,
      );

      if (response == null || (response.statusCode != 200 && response.statusCode != 201)) {
        final msg = response?.data?['message'] ?? 'Unknown error';
        throw Exception('Failed to submit upline payment: $msg');
      }

      return response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : (response.data['data'] as Map<String, dynamic>?) ?? {};
    } catch (e) {
      log('Error submitting upline payment: $e');
      rethrow;
    }
  }

  Future<DailyRoiSettingsModel?> getDailyRoiSettings() async {
    try {
      final response = await _apiClient.get(ApiConstants.dailyRoiSettings);

      if (response == null || response.statusCode != 200) {
        throw Exception('Failed to fetch daily ROI settings: ${response?.statusCode}');
      }

      final responseData = response.data;
      // The response might be wrapped in { data: ... } or be the object directly
      final Map<String, dynamic>? data = responseData is Map<String, dynamic>
          ? (responseData.containsKey('data') && responseData['data'] is Map<String, dynamic>
              ? responseData['data'] as Map<String, dynamic>
              : responseData)
          : null;

      if (data == null || data.isEmpty) return null;
      return DailyRoiSettingsModel.fromJson(data);
    } catch (e) {
      log('Error fetching daily ROI settings: $e');
      rethrow;
    }
  }

  Future<DailyRoiSettingsModel> updateDailyRoiSettings({
    double? dailyRoiPercentage,
    bool? isActive,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (dailyRoiPercentage != null) body['dr_daily_roi_percentage'] = dailyRoiPercentage;
      if (isActive != null) body['dr_is_active'] = isActive;

      final response = await _apiClient.put(
        ApiConstants.dailyRoiSettings,
        data: body,
      );

      if (response == null || (response.statusCode != 200 && response.statusCode != 201)) {
        throw Exception('Failed to update daily ROI settings');
      }

      final responseData = response.data;
      final Map<String, dynamic> data = responseData is Map<String, dynamic>
          ? (responseData.containsKey('data') && responseData['data'] is Map<String, dynamic>
              ? responseData['data'] as Map<String, dynamic>
              : responseData)
          : {};

      return DailyRoiSettingsModel.fromJson(data);
    } catch (e) {
      log('Error updating daily ROI settings: $e');
      rethrow;
    }
  }
}
