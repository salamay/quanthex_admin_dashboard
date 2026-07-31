import 'dart:developer';
import 'package:quanthex_admin/core/network/api_client.dart';
import 'package:quanthex_admin/core/network/api_constants.dart';

import '../domain/models/mining_record_model.dart';
import '../domain/models/mining_payment_model.dart';
import '../domain/models/mining_referral_model.dart';
import '../domain/models/paginated_response.dart';


class MiningRemoteDataSource {
  final ApiClient _apiClient;

  MiningRemoteDataSource(this._apiClient);

  /// Submit a mining payment — backend handles on-chain submission.
  Future<Map<String, dynamic>> submitPayment({
    required String minId,
    required double amount,
    required int chainId,
    String? txData,
    String? rewardSymbol,
  }) async {
    try {
      final body = <String, dynamic>{
        'min_id': minId,
        'amount': amount,
        'chain_id': chainId,
      };
      if (txData != null) body['tx_data'] = txData;
      if (rewardSymbol != null) body['reward_symbol'] = rewardSymbol;

      final response = await _apiClient.post(
        ApiConstants.submitPayment,
        data: body,
      );

      if (response == null || (response.statusCode != 200 && response.statusCode != 201)) {
        final msg = response?.data?['message'] ?? 'Unknown error';
        throw Exception('Failed to submit payment: $msg');
      }

      return response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : (response.data['data'] as Map<String, dynamic>?) ?? {};
    } catch (e) {
      log('Error submitting payment: $e');
      rethrow;
    }
  }

  /// Submit a manual mining payment — admin sends any amount of DOGE.
  Future<Map<String, dynamic>> submitManualPayment({
    required String minId,
    required double amount,
    required int chainId,
    String? txData,
    String? rewardSymbol,
  }) async {
    try {
      final body = <String, dynamic>{
        'min_id': minId,
        'amount': amount,
        'chain_id': chainId,
      };
      if (txData != null) body['tx_data'] = txData;
      if (rewardSymbol != null) body['reward_symbol'] = rewardSymbol;

      final response = await _apiClient.post(
        ApiConstants.manualMiningPayment,
        data: body,
      );

      if (response == null || (response.statusCode != 200 && response.statusCode != 201)) {
        final msg = response?.data?['message'] ?? 'Unknown error';
        throw Exception('Failed to submit manual payment: $msg');
      }

      return response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : (response.data['data'] as Map<String, dynamic>?) ?? {};
    } catch (e) {
      log('Error submitting manual payment: $e');
      rethrow;
    }
  }

  Future<PaginatedResponse<MiningRecordModel>> getAllMinings({
    required int offset,
    required int limit,
    String? packageName,
    int? startDate,
    int? endDate,
    String? email,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'offset': offset.toString(),
        'limit': limit.toString(),
      };

      if (packageName != null && packageName.isNotEmpty) {
        queryParams['packageName'] = packageName;
      }
      if (startDate != null) {
        queryParams['startDate'] = startDate.toString();
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toString();
      }
      if (email != null && email.isNotEmpty) {
        queryParams['email'] = email;
      }

      final response = await _apiClient.get(
        ApiConstants.minings,
        queryParams: queryParams,
      );

      if (response == null || response.statusCode != 200) {
        throw Exception('Failed to fetch minings: ${response?.statusCode}');
      }

      final responseData = response.data;
      final List<dynamic> dataList = responseData['data'] ?? [];
      final int total = responseData['total'] ?? 0;
      final List<dynamic> packageNamesList = responseData['packageNames'] ?? [];

      final minings = dataList
          .map((item) => MiningRecordModel.fromJson(item as Map<String, dynamic>))
          .toList();

      final packages = packageNamesList.map((e) => e.toString()).toList();
      print("dsfsdf:${total}");
      print("dsfsdf:${packages}");
      return PaginatedResponse(data: minings, total: total, packageNames: packages);
    } catch (e) {
      log('Error fetching minings: $e');
      rethrow;
    }
  }

  Future<PaginatedResponse<MiningPaymentModel>> getMiningPayments({
    required int offset,
    required int limit,
    String? status,
    String? packageName,
    String? email,
    int? startDate,
    int? endDate,
    String? minId,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'offset': offset.toString(),
        'limit': limit.toString(),
      };
      if (minId != null && minId.isNotEmpty) queryParams['minId'] = minId;
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (packageName != null && packageName.isNotEmpty) queryParams['packageName'] = packageName;
      if (email != null && email.isNotEmpty) queryParams['email'] = email;
      if (startDate != null) queryParams['startDate'] = startDate.toString();
      if (endDate != null) queryParams['endDate'] = endDate.toString();

      final response = await _apiClient.get(
        ApiConstants.miningPayments,
        queryParams: queryParams,
      );

      if (response == null || response.statusCode != 200) {
        throw Exception('Failed to fetch mining payments: ${response?.statusCode}');
      }

      final responseData = response.data;
      final List<dynamic> dataList = responseData['data'] ?? [];
      final int total = responseData['total'] ?? 0;
      print(responseData);

      final payments = dataList
          .map((item) => MiningPaymentModel.fromJson(item as Map<String, dynamic>))
          .toList();

      return PaginatedResponse(data: payments, total: total);
    } catch (e) {
      log('Error fetching mining payments: $e');
      rethrow;
    }
  }

  /// Fetch direct referrals for a mining (by uid + subscriptionId).
  Future<List<MiningReferralModel>> getDirectReferrals({
    required String uid,
    required String subscriptionId,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'uid': uid,
        'subscriptionId': subscriptionId,
      };

      final response = await _apiClient.get(
        ApiConstants.adminDirectReferrals,
        queryParams: queryParams,
      );

      if (response == null || response.statusCode != 200) {
        throw Exception('Failed to fetch direct referrals: ${response?.statusCode}');
      }

      final responseData = response.data;
      // The interceptor unwraps data.data → the array itself
      final List<dynamic> dataList = responseData is List ? responseData : (responseData['data'] ?? responseData ?? []);

      return dataList
          .map((item) => MiningReferralModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      log('Error fetching direct referrals: $e');
      rethrow;
    }
  }

  /// Fetch indirect referrals for a mining (by uid + subscriptionId).
  Future<List<MiningReferralModel>> getIndirectReferrals({
    required String uid,
    required String subscriptionId,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'uid': uid,
        'subscriptionId': subscriptionId,
      };

      final response = await _apiClient.get(
        ApiConstants.adminIndirectReferrals,
        queryParams: queryParams,
      );
      if (response == null || response.statusCode != 200) {
        throw Exception('Failed to fetch indirect referrals: ${response?.statusCode}');
      }

      final responseData = response.data;
      final List<dynamic> dataList = responseData is List ? responseData : (responseData['data'] ?? responseData ?? []);

      return dataList
          .map((item) => MiningReferralModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      log('Error fetching indirect referrals: $e');
      rethrow;
    }
  }
}
