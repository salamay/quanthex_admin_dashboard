import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:quanthex_admin/data/repositories/staking_repository.dart';
import '../../data/domain/models/staking_payment_model.dart';

class StakingPaymentsProvider extends ChangeNotifier {
  final StakingRepository _repository;

  StakingPaymentsProvider(this._repository);

  final List<StakingPaymentModel> _payments = [];
  List<StakingPaymentModel> get payments => _payments;

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

  String? _searchEmail;
  String? get searchEmail => _searchEmail;

  DateTime? _startDate;
  DateTime? get startDate => _startDate;

  DateTime? _endDate;
  DateTime? get endDate => _endDate;

  bool get hasActiveFilters =>
      _selectedStatus != null ||
      _selectedPlanName != null ||
      (_searchEmail != null && _searchEmail!.isNotEmpty) ||
      _startDate != null ||
      _endDate != null;

  static const int _pageSize = 20;

  void setStatusFilter(String? status) {
    _selectedStatus = status;
    notifyListeners();
  }

  void setPlanNameFilter(String? planName) {
    _selectedPlanName = planName;
    notifyListeners();
  }

  void setSearchEmail(String? email) {
    _searchEmail = email;
    notifyListeners();
  }

  void setDateRange(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    notifyListeners();
  }

  void clearFilters() {
    _selectedStatus = null;
    _selectedPlanName = null;
    _searchEmail = null;
    _startDate = null;
    _endDate = null;
    notifyListeners();
    fetchPayments(refresh: true);
  }

  void applyFilters() {
    fetchPayments(refresh: true);
  }

  int? _dateToMillis(DateTime? dt) {
    if (dt == null) return null;
    return dt.millisecondsSinceEpoch;
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
      final response = await _repository.getStakingPayments(
        offset: 0,
        limit: _pageSize,
        status: _selectedStatus,
        planName: _selectedPlanName,
        email: _searchEmail,
        startDate: _dateToMillis(_startDate),
        endDate: _dateToMillis(_endDate),
      );
      _payments.clear();
      _payments.addAll(response.data);
      _total = response.total;
      _hasError = false;
      _errorMessage = '';
    } catch (e) {
      log('Error fetching staking payments: $e');
      _hasError = true;
      _errorMessage = 'Failed to load staking transactions.';
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
      final response = await _repository.getStakingPayments(
        offset: _payments.length,
        limit: _pageSize,
        status: _selectedStatus,
        planName: _selectedPlanName,
        email: _searchEmail,
        startDate: _dateToMillis(_startDate),
        endDate: _dateToMillis(_endDate),
      );
      _payments.addAll(response.data);
      _total = response.total;
    } catch (e) {
      log('Error loading more staking payments: $e');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }
}
