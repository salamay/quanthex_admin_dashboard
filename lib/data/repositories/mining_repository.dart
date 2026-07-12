import 'package:quanthex_admin/data/datasources/mining_remote_datasource.dart';
import '../domain/models/mining_record_model.dart';
import '../domain/models/mining_payment_model.dart';
import '../domain/models/mining_referral_model.dart';
import '../domain/models/paginated_response.dart';

class MiningRepository {
  final MiningRemoteDataSource _remoteDataSource;

  MiningRepository(this._remoteDataSource);

  Future<PaginatedResponse<MiningRecordModel>> getAllMinings({
    required int offset,
    required int limit,
    String? packageName,
    int? startDate,
    int? endDate,
  }) {
    return _remoteDataSource.getAllMinings(
      offset: offset,
      limit: limit,
      packageName: packageName,
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<PaginatedResponse<MiningPaymentModel>> getMiningPayments({
    required int offset,
    required int limit,
    String? status,
    String? packageName,
    String? email,
    int? startDate,
    int? endDate,
    String? minId,
  }) {
    return _remoteDataSource.getMiningPayments(
      offset: offset,
      limit: limit,
      status: status,
      packageName: packageName,
      email: email,
      startDate: startDate,
      endDate: endDate,
      minId: minId,
    );
  }

  Future<List<MiningReferralModel>> getDirectReferrals({
    required String uid,
    required String subscriptionId,
  }) {
    return _remoteDataSource.getDirectReferrals(
      uid: uid,
      subscriptionId: subscriptionId,
    );
  }

  Future<List<MiningReferralModel>> getIndirectReferrals({
    required String uid,
    required String subscriptionId,
  }) {
    return _remoteDataSource.getIndirectReferrals(
      uid: uid,
      subscriptionId: subscriptionId,
    );
  }
}
