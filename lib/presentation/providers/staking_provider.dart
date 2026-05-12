import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:quanthex_admin/data/repositories/staking_repository.dart';
import '../../data/domain/models/staking_record_model.dart';

class StakingProvider extends ChangeNotifier {
  final StakingRepository _repository;

  StakingProvider(this._repository);

  final List<StakingRecordModel> _stakings = [];
  List<StakingRecordModel> get stakings => _stakings;

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

  bool get hasMore => _stakings.length < _total;

  // Filter state
  String? _selectedPlanName;
  String? get selectedPlanName => _selectedPlanName;

  String? _selectedStatus;
  String? get selectedStatus => _selectedStatus;

  DateTime? _startDate;
  DateTime? get startDate => _startDate;

  DateTime? _endDate;
  DateTime? get endDate => _endDate;

  List<String> _planNames = [];
  List<String> get planNames => _planNames;

  bool get hasActiveFilters =>
      _selectedPlanName != null || _selectedStatus != null || _startDate != null || _endDate != null;

  static const int _pageSize = 20;

  void setPlanNameFilter(String? planName) {
    _selectedPlanName = planName;
    notifyListeners();
  }

  void setStatusFilter(String? status) {
    _selectedStatus = status;
    notifyListeners();
  }

  void setDateRange(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    notifyListeners();
  }

  void clearFilters() {
    _selectedPlanName = null;
    _selectedStatus = null;
    _startDate = null;
    _endDate = null;
    notifyListeners();
    fetchStakings(refresh: true);
  }

  void applyFilters() {
    fetchStakings(refresh: true);
  }

  int? get _startDateMillis =>
      _startDate != null ? _startDate!.millisecondsSinceEpoch : null;

  int? get _endDateMillis => _endDate != null
      ? DateTime(_endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59)
            .millisecondsSinceEpoch
      : null;

  Future<void> fetchStakings({bool refresh = false}) async {
    if (refresh) {
      _stakings.clear();
      _total = 0;
      _hasError = false;
      _errorMessage = '';
    }

    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _repository.getAllStakings(
        offset: 0,
        limit: _pageSize,
        planName: _selectedPlanName,
        status: _selectedStatus,
        startDate: _startDateMillis,
        endDate: _endDateMillis,
      );
      _stakings.clear();
      _stakings.addAll(response.data);
      _total = response.total;
      if (response.packageNames.isNotEmpty) {
        _planNames = response.packageNames;
      }
      _hasError = false;
      _errorMessage = '';
    } catch (e) {
      log('Error fetching stakings: $e');
      _hasError = true;
      _errorMessage = 'Failed to load stakings. Please try again.';
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
      final response = await _repository.getAllStakings(
        offset: _stakings.length,
        limit: _pageSize,
        planName: _selectedPlanName,
        status: _selectedStatus,
        startDate: _startDateMillis,
        endDate: _endDateMillis,
      );
      _stakings.addAll(response.data);
      _total = response.total;
    } catch (e) {
      log('Error loading more stakings: $e');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }
}
