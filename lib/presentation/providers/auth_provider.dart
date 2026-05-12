import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:quanthex_admin/data/repositories/auth_repository.dart';

enum AuthStatus { initial, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;

  AuthProvider(this._repository);

  AuthStatus _status = AuthStatus.initial;
  AuthStatus get status => _status;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  /// Called on app start to check if a stored token exists.
  Future<void> checkAuth() async {
    try {
      final restored = await _repository.restoreSession();
      _status = restored ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    } catch (e) {
      log('Error checking auth: $e');
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await _repository.login(email, password);
      _status = AuthStatus.authenticated;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      log('Login error: $e');
      _errorMessage = _parseError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  String _parseError(dynamic e) {
    final msg = e.toString();
    if (msg.contains('Password is incorrect')) {
      return 'Invalid password. Please try again.';
    }
    if (msg.contains('User not found')) {
      return 'No account found with this email.';
    }
    if (msg.contains('Admin access required')) {
      return 'This account does not have admin privileges.';
    }
    if (msg.contains('SocketException') || msg.contains('Connection refused')) {
      return 'Cannot connect to server. Please check your connection.';
    }
    return 'Login failed. Please try again.';
  }
}
