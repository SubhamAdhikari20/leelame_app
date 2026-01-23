// lib/features/auth/data/datasources/seller_auth_datasource.dart
import 'package:leelame/features/auth/data/models/user_api_model.dart';
import 'package:leelame/features/auth/data/models/user_hive_model.dart';
import 'package:leelame/features/seller/data/models/seller_api_model.dart';
import 'package:leelame/features/seller/data/models/seller_hive_model.dart';

abstract interface class ISellerAuthLocalDatasource {
  Future<SellerHiveModel?> createSeller(SellerHiveModel sellerModel);
  Future<SellerHiveModel?> updateSeller(SellerHiveModel sellerModel);
  Future<SellerHiveModel?> getSellerById(String sellerId);
  Future<SellerHiveModel?> getSellerByPhoneNumber(String phoneNumber);
  Future<SellerHiveModel?> getSellerByBaseUserId(String userId);

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

abstract interface class ISellerAuthRemoteDatasource {
  Future<SellerApiModel?> signUp(
    UserApiModel userModel,
    SellerApiModel sellerModel,
  );
  Future<bool> verifyAccountRegistration(String email, String otp);
  Future<SellerApiModel?> login(
    String identifier,
    String password,
    String role,
  );
  Future<bool> logout();
  Future<SellerApiModel?> getCurrentSeller(String sellerId);

  Future<bool> sendQueuedVerificationEmail({
    String? userId,
    required String email,
    required String otp,
    DateTime? expiry,
  });
}
