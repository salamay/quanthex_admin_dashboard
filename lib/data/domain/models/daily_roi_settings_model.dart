class DailyRoiSettingsModel {
  final String drId;
  final double dailyRoiPercentage;
  final bool isActive;
  final String drCreatedAt;
  final String drUpdatedAt;

  DailyRoiSettingsModel({
    required this.drId,
    required this.dailyRoiPercentage,
    required this.isActive,
    required this.drCreatedAt,
    required this.drUpdatedAt,
  });

  factory DailyRoiSettingsModel.fromJson(Map<String, dynamic> json) {
    return DailyRoiSettingsModel(
      drId: json['dr_id']?.toString() ?? '',
      dailyRoiPercentage:
          (json['dr_daily_roi_percentage'] as num?)?.toDouble() ?? 0.5,
      isActive: json['dr_is_active'] == 1 || json['dr_is_active'] == true,
      drCreatedAt: json['dr_created_at']?.toString() ?? '',
      drUpdatedAt: json['dr_updated_at']?.toString() ?? '',
    );
  }
}
