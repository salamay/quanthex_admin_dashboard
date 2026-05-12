import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:quanthex_admin/data/repositories/staking_repository.dart';
import '../../data/domain/models/staking_settings_model.dart';

class StakingSettingsProvider extends ChangeNotifier {
  final StakingRepository _repository;

  StakingSettingsProvider(this._repository);

  List<StakingSettingsModel> _settings = [];
  List<StakingSettingsModel> get settings => _settings;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasError = false;
  bool get hasError => _hasError;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  Future<void> fetchSettings() async {
    if (_isLoading) return;

    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      _settings = await _repository.getStakingSettings();
      _hasError = false;
      _errorMessage = '';
    } catch (e) {
      log('Error fetching staking settings: $e');
      _hasError = true;
      _errorMessage = 'Failed to load staking settings.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateSetting({
    required String ssId,
    double? rewardPercentage,
    int? referralsPerCycle,
    bool? isActive,
  }) async {
    try {
      final updated = await _repository.updateStakingSettings(
        ssId: ssId,
        rewardPercentage: rewardPercentage,
        referralsPerCycle: referralsPerCycle,
        isActive: isActive,
      );

      final index = _settings.indexWhere((s) => s.ssId == ssId);
      if (index != -1) {
        _settings[index] = updated;
        notifyListeners();
      }
      return true;
    } catch (e) {
      log('Error updating staking setting: $e');
      return false;
    }
  }
}
