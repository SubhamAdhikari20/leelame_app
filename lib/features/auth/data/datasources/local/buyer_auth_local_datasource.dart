// lib/features/auth/data/datasources/local/buyer_auth_local_datasource.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/services/hive/hive_service.dart';
import 'package:leelame/features/auth/data/datasources/buyer_auth_datasource.dart';
import 'package:leelame/features/auth/data/models/user_hive_model.dart';
import 'package:leelame/features/buyer/data/models/buyer_hive_model.dart';

final buyerAuthLocalDatasourceProvider = Provider<IBuyerAuthLocalDatasource>((
  ref,
) {
  final hiveService = ref.read(hiveServiceProvider);
  return BuyerAuthLocalDatasource(hiveService: hiveService);
});

class BuyerAuthLocalDatasource implements IBuyerAuthLocalDatasource {
  final HiveService _hiveService;

  BuyerAuthLocalDatasource({required HiveService hiveService})
    : _hiveService = hiveService;

  @override
  Future<BuyerHiveModel?> getBuyerByUsername(String username) async {
    final result = await _hiveService.getBuyerByUsername(username);
    return Future.value(result);
  }

  @override
  Future<UserHiveModel?> getUserById(String userId) async {
    final result = await _hiveService.getUserById(userId);
    return Future.value(result);
  }

  @override
  Future<BuyerHiveModel?> updateBuyer(BuyerHiveModel buyerModel) async {
    final result = await _hiveService.updateBuyer(buyerModel);
    return Future.value(result);
  }

  @override
  Future<UserHiveModel?> updateBaseUser(UserHiveModel userModel) async {
    final result = await _hiveService.updateUser(userModel);
    return Future.value(result);
  }

  @override
  Future<UserHiveModel?> getUserByEmail(String email) async {
    final result = await _hiveService.getUserByEmail(email);
    return Future.value(result);
  }

  @override
  Future<BuyerHiveModel?> getBuyerByPhoneNumber(String phoneNumber) async {
    final result = await _hiveService.getBuyerByPhoneNumber(phoneNumber);
    return Future.value(result);
  }

  @override
  Future<BuyerHiveModel?> getBuyerById(String buyerId) async {
    final result = await _hiveService.getBuyerById(buyerId);
    return Future.value(result);
  }

  @override
  Future<BuyerHiveModel?> getBuyerByBaseUserId(String userId) async {
    final result = await _hiveService.getBuyerByBaseUserId(userId);
    return Future.value(result);
  }

  @override
  Future<BuyerHiveModel?> createBuyer(BuyerHiveModel buyerModel) async {
    final result = await _hiveService.createBuyer(buyerModel);
    return Future.value(result);
  }

  @override
  Future<UserHiveModel?> createBaseUser(UserHiveModel userModel) async {
    final result = await _hiveService.createUser(userModel);
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
