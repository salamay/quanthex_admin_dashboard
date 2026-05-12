class PaymentStatusModel {
  final List<int> paidTiers;
  final int? nextTier;
  final bool isEligibleForPayment;

  static const List<int> allTiers = [6, 36, 216, 1296];

  PaymentStatusModel({
    this.paidTiers = const [],
    this.nextTier,
    this.isEligibleForPayment = false,
  });

  /// The next tier the user needs to reach (even if not yet qualified).
  int? get nextRequiredTier {
    for (final tier in allTiers) {
      if (!paidTiers.contains(tier)) return tier;
    }
    return null; // All tiers paid
  }

  /// Whether all 4 tiers have been paid.
  bool get allTiersPaid => paidTiers.length >= allTiers.length;

  factory PaymentStatusModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return PaymentStatusModel.empty();
    final rawTiers = json['paid_tiers'];
    final List<int> parsedTiers = [];
    if (rawTiers is List) {
      for (final e in rawTiers) {
        if (e != null && e is num) {
          parsedTiers.add(e.toInt());
        }
      }
    }
    final rawNextTier = json['next_tier'];
    return PaymentStatusModel(
      paidTiers: parsedTiers,
      nextTier: rawNextTier is num ? rawNextTier.toInt() : null,
      isEligibleForPayment: json['is_eligible_for_payment'] == true,
    );
  }

  factory PaymentStatusModel.empty() {
    return PaymentStatusModel();
  }
}
