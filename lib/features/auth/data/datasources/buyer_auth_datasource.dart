// lib/features/auth/data/datasources/buyer_auth_datasource.dart
import 'package:leelame/features/auth/data/models/user_api_model.dart';
import 'package:leelame/features/auth/data/models/user_hive_model.dart';
import 'package:leelame/features/buyer/data/models/buyer_api_model.dart';
import 'package:leelame/features/buyer/data/models/buyer_hive_model.dart';

abstract interface class IBuyerAuthLocalDatasource {
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
  Future<bool> isUsernameExists(String username);
  Future<bool> isPhoneNumberExists(String phoneNumber);
}

abstract interface class IBuyerAuthRemoteDatasource {
  Future<BuyerApiModel?> signUp(
    UserApiModel userModel,
    BuyerApiModel buyerModel,
  );
  Future<BuyerApiModel?> login(String identifier, String password, String role);
  Future<UserApiModel?> getCurrentUser(String userId);
  Future<BuyerApiModel?> getCurrentBuyer(String buyerId);
  Future<bool> logout();

  Future<bool> isEmailExists(String email);
  Future<bool> isUsernameExists(String username);
  Future<bool> isPhoneNumberExists(String phoneNumber);
}
