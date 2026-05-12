import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:quanthex_admin/data/repositories/mining_repository.dart';

import '../../data/domain/models/mining_record_model.dart';

class MiningProvider extends ChangeNotifier {
  final MiningRepository _repository;

  MiningProvider(this._repository);

  final List<MiningRecordModel> _minings = [];
  List<MiningRecordModel> get minings => _minings;

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

  bool get hasMore => _minings.length < _total;

  // Filter state
  String? _selectedPackageName;
  String? get selectedPackageName => _selectedPackageName;

  DateTime? _startDate;
  DateTime? get startDate => _startDate;

  DateTime? _endDate;
  DateTime? get endDate => _endDate;

  List<String> _packageNames = [];
  List<String> get packageNames => _packageNames;

  bool get hasActiveFilters =>
      _selectedPackageName != null || _startDate != null || _endDate != null;

  static const int _pageSize = 20;

  void setPackageNameFilter(String? packageName) {
    _selectedPackageName = packageName;
    notifyListeners();
  }

  void setDateRange(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    notifyListeners();
  }

  void clearFilters() {
    _selectedPackageName = null;
    _startDate = null;
    _endDate = null;
    notifyListeners();
    fetchMinings(refresh: true);
  }

  void applyFilters() {
    fetchMinings(refresh: true);
  }

  int? get _startDateMillis =>
      _startDate != null ? _startDate!.millisecondsSinceEpoch : null;

  int? get _endDateMillis => _endDate != null
      ? DateTime(_endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59)
            .millisecondsSinceEpoch
      : null;

  Future<void> fetchMinings({bool refresh = false}) async {
    if (refresh) {
      _minings.clear();
      _total = 0;
      _hasError = false;
      _errorMessage = '';
    }

    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _repository.getAllMinings(
        offset: 0,
        limit: _pageSize,
        packageName: _selectedPackageName,
        startDate: _startDateMillis,
        endDate: _endDateMillis,
      );
      _minings.clear();
      _minings.addAll(response.data);
      _total = response.total;
      if (response.packageNames.isNotEmpty) {
        _packageNames = response.packageNames;
      }
      _hasError = false;
      _errorMessage = '';
    } catch (e) {
      log('Error fetching minings: $e');
      _hasError = true;
      _errorMessage = 'Failed to load minings. Please try again.';
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
      final response = await _repository.getAllMinings(
        offset: _minings.length,
        limit: _pageSize,
        packageName: _selectedPackageName,
        startDate: _startDateMillis,
        endDate: _endDateMillis,
      );
      _minings.addAll(response.data);
      _total = response.total;
    } catch (e) {
      log('Error loading more minings: $e');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }
}
