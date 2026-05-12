import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:quanthex_admin/data/repositories/staking_repository.dart';
import '../../data/domain/models/upline_payment_model.dart';

class UplinePaymentsProvider extends ChangeNotifier {
  final StakingRepository _repository;

  UplinePaymentsProvider(this._repository);

  final List<UplinePaymentModel> _payments = [];
  List<UplinePaymentModel> get payments => _payments;

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

  bool get hasMore => _payments.length < _total;

  // Filter state
  String? _selectedStatus;
  String? get selectedStatus => _selectedStatus;

  String? _selectedPlanName;
  String? get selectedPlanName => _selectedPlanName;

  bool get hasActiveFilters => _selectedStatus != null || _selectedPlanName != null;

  static const int _pageSize = 20;

  void setStatusFilter(String? status) {
    _selectedStatus = status;
    notifyListeners();
  }

  void setPlanNameFilter(String? planName) {
    _selectedPlanName = planName;
    notifyListeners();
  }

  void clearFilters() {
    _selectedStatus = null;
    _selectedPlanName = null;
    notifyListeners();
    fetchPayments(refresh: true);
  }

  void applyFilters() {
    fetchPayments(refresh: true);
  }

  Future<void> fetchPayments({bool refresh = false}) async {
    if (refresh) {
      _payments.clear();
      _total = 0;
      _hasError = false;
      _errorMessage = '';
    }

    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _repository.getUplinePayments(
        offset: 0,
        limit: _pageSize,
        status: _selectedStatus,
        planName: _selectedPlanName,
      );
      _payments.clear();
      _payments.addAll(response.data);
      _total = response.total;
      _hasError = false;
      _errorMessage = '';
    } catch (e) {
      log('Error fetching upline payments: $e');
      _hasError = true;
      _errorMessage = 'Failed to load upline payments. Please try again.';
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
      final response = await _repository.getUplinePayments(
        offset: _payments.length,
        limit: _pageSize,
        status: _selectedStatus,
        planName: _selectedPlanName,
      );
      _payments.addAll(response.data);
      _total = response.total;
    } catch (e) {
      log('Error loading more upline payments: $e');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }
}
