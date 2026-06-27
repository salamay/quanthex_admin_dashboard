import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:quanthex_admin/data/repositories/user_repository.dart';
import 'package:quanthex_admin/data/domain/models/user_model.dart';

class UsersProvider extends ChangeNotifier {
  final UserRepository _repository;

  UsersProvider(this._repository);

  final List<UserModel> _users = [];
  List<UserModel> get users => _users;

  int _total = 0;
  int get total => _total;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  bool _hasError = false;
  bool get hasError => _hasError;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  bool get hasMore => _users.length < _total;

  String? _searchQuery;
  String? get searchQuery => _searchQuery;

  static const int _pageSize = 20;

  void setSearchQuery(String? query) {
    _searchQuery = (query != null && query.trim().isEmpty) ? null : query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = null;
    notifyListeners();
    fetchUsers(refresh: true);
  }

  void applySearch() {
    fetchUsers(refresh: true);
  }

  Future<void> fetchUsers({bool refresh = false}) async {
    if (refresh) {
      _users.clear();
      _total = 0;
      _hasError = false;
      _errorMessage = '';
    }

    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _repository.getAllUsers(
        offset: 0,
        limit: _pageSize,
        search: _searchQuery,
      );
      _users.clear();
      _users.addAll(response.data);
      _total = response.total;
      _hasError = false;
      _errorMessage = '';
    } catch (e) {
      log('Error fetching users: $e');
      _hasError = true;
      _errorMessage = 'Failed to load users. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final response = await _repository.getAllUsers(
        offset: _users.length,
        limit: _pageSize,
        search: _searchQuery,
      );
      _users.addAll(response.data);
      _total = response.total;
    } catch (e) {
      log('Error loading more users: $e');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }
}
