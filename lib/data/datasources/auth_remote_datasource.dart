import 'dart:developer';
import 'package:quanthex_admin/core/network/api_client.dart';
import 'package:quanthex_admin/core/network/api_constants.dart';

class AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSource(this._apiClient);

  /// Returns the JWT token string on success, throws on failure.
  Future<String> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );

      if (response == null) {
        throw Exception('No response from server');
      }

      if (response.statusCode != null && response.statusCode! >= 400) {
        final message = response.data?['message'] ?? 'Login failed';
        throw Exception(message);
      }

      // The interceptor wraps response as { status, message, data }
      // where data is the JWT token string
      final token = response.data['data'];
      if (token == null || token.toString().isEmpty) {
        throw Exception('No token returned');
      }

      return token.toString();
    } catch (e) {
      log('Login error: $e');
      rethrow;
    }
  }
}
