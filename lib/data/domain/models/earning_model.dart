class EarningModel {
  final double directEarning;
  final double indirectEarning;
  final double totalEarning;

  EarningModel({
    required this.directEarning,
    required this.indirectEarning,
    required this.totalEarning,
  });

  factory EarningModel.fromJson(Map<String, dynamic> json) {
    return EarningModel(
      directEarning: (json['directEarning'] as num?)?.toDouble() ?? 0.0,
      indirectEarning: (json['indirectEarning'] as num?)?.toDouble() ?? 0.0,
      totalEarning: (json['totalEarning'] as num?)?.toDouble() ?? 0.0,
    );
  }

  factory EarningModel.empty() {
    return EarningModel(directEarning: 0, indirectEarning: 0, totalEarning: 0);
  }
}
