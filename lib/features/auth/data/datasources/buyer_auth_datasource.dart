// lib/features/auth/data/datasources/buyer_auth_datasource.dart
import 'package:leelame/features/auth/data/models/user_hive_model.dart';
import 'package:leelame/features/buyer/data/models/buyer_hive_model.dart';

abstract interface class IBuyerAuthDatasource {
  Future<BuyerHiveModel?> signUp(
    UserHiveModel userModel,
    BuyerHiveModel buyerModel,
  );
  Future<BuyerHiveModel?> login(
    String identifier,
    String password,
    String role,
  );
  Future<UserHiveModel?> getCurrentUser(String userId);
  Future<BuyerHiveModel?> getCurrentBuyer(String buyerId);
  Future<bool> logout();

  Future<bool> isEmailExists(String email);
}
