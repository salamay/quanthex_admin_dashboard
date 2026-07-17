import 'dart:convert';

class MiningReferralModel {
  final String referralId;
  final String referralUid;
  final String referreeUid;
  final String? referralSubscriptionId;
  final String? referreeSubscriptionId;
  final String? referralCreatedAt;
  final int? depth;
  final List<String> referralPath;
  final String? referreeEmail;
  final String? referreeReferralCode;

  MiningReferralModel({
    required this.referralId,
    required this.referralUid,
    required this.referreeUid,
    this.referralSubscriptionId,
    this.referreeSubscriptionId,
    this.referralCreatedAt,
    this.depth,
    this.referralPath = const [],
    this.referreeEmail,
    this.referreeReferralCode,
  });

  /// Returns the level relative to [viewingSubscriptionId].
  /// Takes the sublist starting from the viewing subscription,
  /// and the level = length of that sublist.
  /// E.g. path ["A","B","C"], viewing "A" → sublist ["A","B","C"] → level 3,
  /// but since the viewing sub itself is level 1 (direct),
  /// the last item is at level = sublist.length.
  /// Returns -1 if the viewing ID is not found.
  int levelFor(String viewingSubscriptionId) {
    if (referralPath.isEmpty) return -1;
    final viewPos = referralPath.indexOf(viewingSubscriptionId);
    if (viewPos < 0) return -1;
    // sublist from the viewing position onward
    final sub = referralPath.sublist(viewPos);
    // level = length of sublist (position 0 in sub = level 1, last = level sub.length)
    print("referralPath: $referralPath length: ${sub.length} viewingSubscriptionId:$viewingSubscriptionId");
    return sub.length;
  }

  /// Parses from ReferralDto shape: { info: ReferralEntity, profile: ProfileEntity }
  factory MiningReferralModel.fromJson(Map<String, dynamic> json) {
    final info = json['info'] as Map<String, dynamic>? ?? {};
    final profile = json['profile'] as Map<String, dynamic>? ?? {};

    List<String> parsedPath = [];
    final rawPath = info['referral_path'];
    if (rawPath is List) {
      parsedPath = rawPath.map((e) => e.toString()).toList();
    } else if (rawPath is String && rawPath.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawPath);
        if (decoded is List) {
          parsedPath = decoded.map((e) => e.toString()).toList();
        }
      } catch (_) {}
    }

    return MiningReferralModel(
      referralId: info['referral_id']?.toString() ?? '',
      referralUid: info['referral_uid']?.toString() ?? '',
      referreeUid: info['referree_uid']?.toString() ?? '',
      referralSubscriptionId: info['referral_subscription_id']?.toString(),
      referreeSubscriptionId: info['referree_subscription_id']?.toString(),
      referralCreatedAt: info['referral_created_at']?.toString(),
      depth: info['depth'] is num ? (info['depth'] as num).toInt() : null,
      referralPath: parsedPath,
      referreeEmail: profile['email']?.toString(),
      referreeReferralCode: profile['referral_code']?.toString(),
    );
  }
}
