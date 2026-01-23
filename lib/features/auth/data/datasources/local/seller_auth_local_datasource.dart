// lib/features/auth/data/datasources/local/seller_auth_local_datasource.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/services/hive/hive_service.dart';
import 'package:leelame/features/auth/data/datasources/seller_auth_datasource.dart';
import 'package:leelame/features/auth/data/models/user_hive_model.dart';
import 'package:leelame/features/seller/data/models/seller_hive_model.dart';

final sellerAuthLocalDatasourceProvider = Provider<ISellerAuthLocalDatasource>((
  ref,
) {
  final hiveService = ref.read(hiveServiceProvider);
  return SellerAuthLocalDatasource(hiveService: hiveService);
});

class SellerAuthLocalDatasource implements ISellerAuthLocalDatasource {
  final HiveService _hiveService;

  SellerAuthLocalDatasource({required HiveService hiveService})
    : _hiveService = hiveService;

  @override
  Future<UserHiveModel?> createBaseUser(UserHiveModel userModel) async {
    final result = await _hiveService.createUser(userModel);
    return Future.value(result);
  }

  @override
  Future<SellerHiveModel?> createSeller(SellerHiveModel sellerModel) async {
    final result = await _hiveService.createSeller(sellerModel);
    return Future.value(result);
  }

  @override
  Future<UserHiveModel?> updateBaseUser(UserHiveModel userModel) async {
    final result = await _hiveService.updateUser(userModel);
    return Future.value(result);
  }

  @override
  Future<SellerHiveModel?> updateSeller(SellerHiveModel sellerModel) async {
    final result = await _hiveService.updateSeller(sellerModel);
    return Future.value(result);
  }

  @override
  Future<SellerHiveModel?> getSellerByBaseUserId(String userId) async {
    final result = await _hiveService.getSellerByBaseUserId(userId);
    return Future.value(result);
  }

  @override
  Future<SellerHiveModel?> getSellerById(String sellerId) async {
    final result = await _hiveService.getSellerById(sellerId);
    return Future.value(result);
  }

  @override
  Future<SellerHiveModel?> getSellerByPhoneNumber(String phoneNumber) async {
    final result = await _hiveService.getSellerByPhoneNumber(phoneNumber);
    return Future.value(result);
  }

  @override
  Future<UserHiveModel?> getUserByEmail(String email) async {
    final result = await _hiveService.getUserByEmail(email);
    return Future.value(result);
  }

  @override
  Future<UserHiveModel?> getUserById(String userId) async {
    final result = await _hiveService.getUserById(userId);
    return Future.value(result);
  }

  @override
  Future<void> queueOtpEmail({
    required String toEmail,
    required String fullName,
    required String otp,
    DateTime? expiryDate,
  }) async {
    await _hiveService.queueOtpEmail(
      toEmail: toEmail,
      fullName: fullName,
      otp: otp,
      expiryDate: expiryDate,
    );
  }
}
