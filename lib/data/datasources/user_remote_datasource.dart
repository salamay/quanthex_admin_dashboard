import 'dart:developer';
import 'package:quanthex_admin/core/network/api_client.dart';
import 'package:quanthex_admin/core/network/api_constants.dart';
import 'package:quanthex_admin/data/domain/models/user_model.dart';
import 'package:quanthex_admin/data/domain/models/user_referral_model.dart';
import 'package:quanthex_admin/data/domain/models/user_subscription_model.dart';
import 'package:quanthex_admin/data/domain/models/completed_hash_user_model.dart';
import 'package:quanthex_admin/data/domain/models/paginated_response.dart';

class UserRemoteDataSource {
  final ApiClient _apiClient;

  UserRemoteDataSource(this._apiClient);

  Future<PaginatedResponse<UserModel>> getAllUsers({
    required int offset,
    required int limit,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'offset': offset.toString(),
        'limit': limit.toString(),
      };
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _apiClient.get(
        ApiConstants.users,
        queryParams: queryParams,
      );

      if (response == null || response.statusCode != 200) {
        throw Exception('Failed to fetch users: ${response?.statusCode}');
      }

      final responseData = response.data;
      final List<dynamic> dataList = responseData['data'] ?? [];
      final int total = responseData['total'] ?? 0;

      final users = dataList
          .map((item) => UserModel.fromJson(item as Map<String, dynamic>))
          .toList();

      return PaginatedResponse(data: users, total: total);
    } catch (e) {
      log('Error fetching users: $e');
      rethrow;
    }
  }

  Future<PaginatedResponse<UserReferralModel>> getUserReferrals({
    required String uid,
    required int offset,
    required int limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'uid': uid,
        'offset': offset.toString(),
        'limit': limit.toString(),
      };

      final response = await _apiClient.get(
        ApiConstants.userReferrals,
        queryParams: queryParams,
      );

      if (response == null || response.statusCode != 200) {
        throw Exception('Failed to fetch referrals: ${response?.statusCode}');
      }

      final responseData = response.data;
      final List<dynamic> dataList = responseData['data'] ?? [];
      final int total = responseData['total'] ?? 0;

      final referrals = dataList
          .map((item) => UserReferralModel.fromJson(item as Map<String, dynamic>))
          .toList();

      return PaginatedResponse(data: referrals, total: total);
    } catch (e) {
      log('Error fetching user referrals: $e');
      rethrow;
    }
  }

  Future<PaginatedResponse<UserSubscriptionModel>> getUserSubscriptions({
    required String uid,
    required int offset,
    required int limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'uid': uid,
        'offset': offset.toString(),
        'limit': limit.toString(),
      };

      final response = await _apiClient.get(
        ApiConstants.userSubscriptions,
        queryParams: queryParams,
      );

      if (response == null || response.statusCode != 200) {
        throw Exception('Failed to fetch subscriptions: ${response?.statusCode}');
      }

      final responseData = response.data;
      final List<dynamic> dataList = responseData['data'] ?? [];
      final int total = responseData['total'] ?? 0;

      final subscriptions = dataList
          .map((item) => UserSubscriptionModel.fromJson(item as Map<String, dynamic>))
          .toList();

      return PaginatedResponse(data: subscriptions, total: total);
    } catch (e) {
      log('Error fetching user subscriptions: $e');
      rethrow;
    }
  }

  Future<PaginatedResponse<CompletedHashUserModel>> getCompletedHashUsers({
    required int minReferrals,
    required int offset,
    required int limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'minReferrals': minReferrals.toString(),
        'offset': offset.toString(),
        'limit': limit.toString(),
      };

      final response = await _apiClient.get(
        ApiConstants.completedHashUsers,
        queryParams: queryParams,
      );

      if (response == null || response.statusCode != 200) {
        throw Exception('Failed to fetch completed hash users: ${response?.statusCode}');
      }

      final responseData = response.data;
      final List<dynamic> dataList = responseData['data'] ?? [];
      final int total = responseData['total'] ?? 0;

      final users = dataList
          .map((item) => CompletedHashUserModel.fromJson(item as Map<String, dynamic>))
          .toList();

      return PaginatedResponse(data: users, total: total);
    } catch (e) {
      log('Error fetching completed hash users: $e');
      rethrow;
    }
  }
}
