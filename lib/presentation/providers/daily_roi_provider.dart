import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:quanthex_admin/data/repositories/staking_repository.dart';
import '../../data/domain/models/daily_roi_eligible_model.dart';
import '../../data/domain/models/daily_roi_payment_model.dart';

class DailyRoiProvider extends ChangeNotifier {
  final StakingRepository _repository;

  DailyRoiProvider(this._repository);

  // ── Eligible state ───────────────────────────────────────────────────
  List<DailyRoiEligibleModel> _eligible = [];
  List<DailyRoiEligibleModel> get eligible => _eligible;

  List<DailyRoiEligibleModel> _alreadyPaid = [];
  List<DailyRoiEligibleModel> get alreadyPaid => _alreadyPaid;

  double _roiPercentage = 0;
  double get roiPercentage => _roiPercentage;

  double _totalPayoutToday = 0;
  double get totalPayoutToday => _totalPayoutToday;

  bool _isLoadingEligible = false;
  bool get isLoadingEligible => _isLoadingEligible;

  bool _hasEligibleError = false;
  bool get hasEligibleError => _hasEligibleError;

  String _eligibleErrorMessage = '';
  String get eligibleErrorMessage => _eligibleErrorMessage;

  // ── Pay state ────────────────────────────────────────────────────────
  bool _isPaying = false;
  bool get isPaying => _isPaying;

  String? _payingStakingId;
  String? get payingStakingId => _payingStakingId;

  bool _isPayingAll = false;
  bool get isPayingAll => _isPayingAll;

  String? _payMessage;
  String? get payMessage => _payMessage;

  bool _paySuccess = false;
  bool get paySuccess => _paySuccess;

  // ── Payment history state ────────────────────────────────────────────
  final List<DailyRoiPaymentModel> _payments = [];
  List<DailyRoiPaymentModel> get payments => _payments;

  int _paymentsTotal = 0;
  int get paymentsTotal => _paymentsTotal;

  bool _isLoadingPayments = false;
  bool get isLoadingPayments => _isLoadingPayments;

  bool _isLoadingMorePayments = false;
  bool get isLoadingMorePayments => _isLoadingMorePayments;

  bool _hasPaymentsError = false;
  bool get hasPaymentsError => _hasPaymentsError;

  String _paymentsErrorMessage = '';
  String get paymentsErrorMessage => _paymentsErrorMessage;

  bool get hasMorePayments => _payments.length < _paymentsTotal;

  // Payment history filters
  String? _filterStatus;
  String? get filterStatus => _filterStatus;

  String? _filterEmail;
  String? get filterEmail => _filterEmail;

  String? _filterPaymentDate;
  String? get filterPaymentDate => _filterPaymentDate;

  bool get hasActiveFilters =>
      _filterStatus != null ||
      (_filterEmail != null && _filterEmail!.isNotEmpty) ||
      _filterPaymentDate != null;

  static const int _pageSize = 20;

  void setFilterStatus(String? status) {
    _filterStatus = status;
    notifyListeners();
  }

  void setFilterEmail(String? email) {
    _filterEmail = email;
    notifyListeners();
  }

  void setFilterPaymentDate(String? date) {
    _filterPaymentDate = date;
    notifyListeners();
  }

  void clearFilters() {
    _filterStatus = null;
    _filterEmail = null;
    _filterPaymentDate = null;
    notifyListeners();
    fetchPaymentHistory(refresh: true);
  }

  void applyFilters() {
    fetchPaymentHistory(refresh: true);
  }

  void clearPayMessage() {
    _payMessage = null;
    _paySuccess = false;
    notifyListeners();
  }

  // ── Fetch eligible ───────────────────────────────────────────────────

  Future<void> fetchEligible() async {
    if (_isLoadingEligible) return;

    _isLoadingEligible = true;
    _hasEligibleError = false;
    _eligibleErrorMessage = '';
    notifyListeners();

    try {
      final result = await _repository.getDailyRoiEligible();
      _eligible = result['eligible'] as List<DailyRoiEligibleModel>;
      _alreadyPaid = result['alreadyPaid'] as List<DailyRoiEligibleModel>;
      _roiPercentage = result['roiPercentage'] as double;
      _totalPayoutToday = result['totalPayoutToday'] as double;
      _hasEligibleError = false;
    } catch (e) {
      log('Error fetching daily ROI eligible: $e');
      _hasEligibleError = true;
      _eligibleErrorMessage = 'Failed to load eligible stakings.';
    } finally {
      _isLoadingEligible = false;
      notifyListeners();
    }
  }

  // ── Pay single (called after tx is signed via SendTokenView) ──────────

  /// Called when payment is completed via SendTokenView navigation.
  /// Simply refreshes the eligible list and shows a success message.
  Future<void> onPaymentCompleted(String stakingId) async {
    _payMessage = 'Payment confirmed for staking.';
    _paySuccess = true;
    notifyListeners();
    await fetchEligible();
  }

  // ── Pay all (batch sign and submit) ──────────────────────────────────

  /// Batch pay: accepts a list of signed transaction items and submits them
  /// all to the backend. Each item must contain staking_id, tx_data, chain_id.
  Future<void> payAll(List<Map<String, dynamic>> signedItems) async {
    if (_isPayingAll) return;

    _isPayingAll = true;
    _payMessage = null;
    _paySuccess = false;
    notifyListeners();

    try {
      final result = await _repository.payAllDailyRoi(signedItems);
      final paid = result['paid'] ?? 0;
      final failed = result['failed'] ?? 0;
      final totalPayout = result['totalPayout'] ?? 0;
      _payMessage = 'Paid: $paid, Failed: $failed, Total Payout: \$${(totalPayout is double ? totalPayout : (totalPayout as num).toDouble()).toStringAsFixed(2)}';
      _paySuccess = true;
      // Refresh eligible list
      await fetchEligible();
    } catch (e) {
      log('Error paying all daily ROI: $e');
      _payMessage = 'Failed to pay all: ${e.toString().replaceFirst('Exception: ', '')}';
      _paySuccess = false;
      notifyListeners();
    } finally {
      _isPayingAll = false;
      notifyListeners();
    }
  }

  // ── Payment history ──────────────────────────────────────────────────

  Future<void> fetchPaymentHistory({bool refresh = false}) async {
    if (refresh) {
      _payments.clear();
      _paymentsTotal = 0;
      _hasPaymentsError = false;
      _paymentsErrorMessage = '';
    }

    if (_isLoadingPayments) return;

    _isLoadingPayments = true;
    notifyListeners();

    try {
      final response = await _repository.getDailyRoiPayments(
        offset: 0,
        limit: _pageSize,
        status: _filterStatus,
        email: _filterEmail,
        paymentDate: _filterPaymentDate,
      );
      _payments.clear();
      _payments.addAll(response.data);
      _paymentsTotal = response.total;
      _hasPaymentsError = false;
    } catch (e) {
      log('Error fetching daily ROI payments: $e');
      _hasPaymentsError = true;
      _paymentsErrorMessage = 'Failed to load payment history.';
    } finally {
      _isLoadingPayments = false;
      notifyListeners();
    }
  }

  Future<void> loadMorePayments() async {
    if (_isLoadingMorePayments || !hasMorePayments) return;

    _isLoadingMorePayments = true;
    notifyListeners();

    try {
      final response = await _repository.getDailyRoiPayments(
        offset: _payments.length,
        limit: _pageSize,
        status: _filterStatus,
        email: _filterEmail,
        paymentDate: _filterPaymentDate,
      );
      _payments.addAll(response.data);
      _paymentsTotal = response.total;
    } catch (e) {
      log('Error loading more daily ROI payments: $e');
    } finally {
      _isLoadingMorePayments = false;
      notifyListeners();
    }
  }
}
