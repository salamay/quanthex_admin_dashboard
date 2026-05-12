import 'package:quanthex_admin/core/network/api_client.dart';
import 'package:quanthex_admin/data/datasources/auth_remote_datasource.dart';
import 'package:quanthex_admin/data/local/token_storage.dart';

class AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final TokenStorage _tokenStorage;
  final ApiClient _apiClient;

  AuthRepository(this._remoteDataSource, this._tokenStorage, this._apiClient);

  Future<String> login(String email, String password) async {
    final token = await _remoteDataSource.login(email, password);
    await _tokenStorage.saveToken(token);
    _apiClient.setToken(token);
    return token;
  }

  Future<void> logout() async {
    await _tokenStorage.clearToken();
    _apiClient.setToken('');
  }

  Future<bool> hasToken() async {
    return await _tokenStorage.hasToken();
  }

  /// Restores token from storage and attaches it to the ApiClient.
  /// Returns true if a stored token was found.
  Future<bool> restoreSession() async {
    final token = await _tokenStorage.getToken();
    if (token != null && token.isNotEmpty) {
      _apiClient.setToken(token);
      return true;
    }
    return false;
  }
}
