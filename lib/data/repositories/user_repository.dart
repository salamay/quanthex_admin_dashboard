import 'package:quanthex_admin/data/datasources/user_remote_datasource.dart';
import 'package:quanthex_admin/data/domain/models/user_model.dart';
import 'package:quanthex_admin/data/domain/models/user_referral_model.dart';
import 'package:quanthex_admin/data/domain/models/user_subscription_model.dart';
import 'package:quanthex_admin/data/domain/models/paginated_response.dart';

class UserRepository {
  final UserRemoteDataSource _remoteDataSource;

  UserRepository(this._remoteDataSource);

  Future<PaginatedResponse<UserModel>> getAllUsers({
    required int offset,
    required int limit,
    String? search,
  }) {
    return _remoteDataSource.getAllUsers(
      offset: offset,
      limit: limit,
      search: search,
    );
  }

  Future<PaginatedResponse<UserReferralModel>> getUserReferrals({
    required String uid,
    required int offset,
    required int limit,
  }) {
    return _remoteDataSource.getUserReferrals(
      uid: uid,
      offset: offset,
      limit: limit,
    );
  }

  Future<PaginatedResponse<UserSubscriptionModel>> getUserSubscriptions({
    required String uid,
    required int offset,
    required int limit,
  }) {
    return _remoteDataSource.getUserSubscriptions(
      uid: uid,
      offset: offset,
      limit: limit,
    );
  }
}
