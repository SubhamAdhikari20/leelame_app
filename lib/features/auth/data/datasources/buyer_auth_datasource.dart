// lib/features/auth/data/datasources/buyer_auth_datasource.dart
import 'package:leelame/features/auth/data/models/user_api_model.dart';
import 'package:leelame/features/auth/data/models/user_hive_model.dart';
import 'package:leelame/features/buyer/data/models/buyer_api_model.dart';
import 'package:leelame/features/buyer/data/models/buyer_hive_model.dart';

abstract interface class IBuyerAuthLocalDatasource {
  Future<BuyerHiveModel?> createBuyer(BuyerHiveModel buyerModel);
  Future<BuyerHiveModel?> updateBuyer(BuyerHiveModel buyerModel);
  Future<BuyerHiveModel?> getBuyerById(String buyerId);
  Future<BuyerHiveModel?> getBuyerByUsername(String username);
  Future<BuyerHiveModel?> getBuyerByPhoneNumber(String phoneNumber);
  Future<BuyerHiveModel?> getBuyerByBaseUserId(String userId);

  Future<UserHiveModel?> createBaseUser(UserHiveModel userModel);
  Future<UserHiveModel?> updateBaseUser(UserHiveModel userModel);
  Future<UserHiveModel?> getUserById(String userId);
  Future<UserHiveModel?> getUserByEmail(String email);

  Future<void> queueOtpEmail({
    required String toEmail,
    required String fullName,
    required String otp,
    DateTime? expiryDate,
  });
}

abstract interface class IBuyerAuthRemoteDatasource {
  Future<BuyerApiModel?> signUp(
    UserApiModel userModel,
    BuyerApiModel buyerModel,
  );
  Future<bool> verifyAccountRegistration(String username, String otp);
  Future<BuyerApiModel?> login(String identifier, String password, String role);
  Future<bool> logout();

  Future<bool> sendQueuedVerificationEmail({
    String? userId,
    required String email,
    required String otp,
    DateTime? expiry,
  });
}
