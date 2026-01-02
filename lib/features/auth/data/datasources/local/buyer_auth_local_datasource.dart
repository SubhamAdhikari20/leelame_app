// lib/features/auth/data/datasources/local/buyer_auth_local_datasource.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/services/hive/hive_service.dart';
import 'package:leelame/features/auth/data/datasources/buyer_auth_datasource.dart';
import 'package:leelame/features/auth/data/models/user_hive_model.dart';
import 'package:leelame/features/buyer/data/models/buyer_hive_model.dart';

final buyerAuthLocalDatasourceProvider = Provider<IBuyerAuthDatasource>((ref) {
  final hiveService = ref.read(hiveServiceProvider);
  return BuyerAuthLocalDatasource(hiveService: hiveService);
});

class BuyerAuthLocalDatasource implements IBuyerAuthDatasource {
  final HiveService _hiveService;

  BuyerAuthLocalDatasource({required HiveService hiveService})
    : _hiveService = hiveService;

  @override
  Future<BuyerHiveModel?> login(
    String identifier,
    String password,
    String role,
  ) async {
    try {
      final buyer = await _hiveService.loginBuyer(identifier, password, role);
      return Future.value(buyer);
    } catch (e) {
      return Future.value(null);
    }
  }

  @override
  Future<bool> logout() async {
    try {
      await _hiveService.logoutBuyer();
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  }

  @override
  Future<BuyerHiveModel?> signUp(
    UserHiveModel userModel,
    BuyerHiveModel buyerModel,
  ) async {
    try {
      await _hiveService.signUpBuyer(userModel, buyerModel);
      return Future.value(buyerModel);
    } catch (e) {
      return Future.value(null);
    }
  }

  @override
  Future<UserHiveModel?> getCurrentUser(String userId) async {
    try {
      final user = await _hiveService.getCurrentUser(userId);
      return Future.value(user);
    } catch (e) {
      return Future.value(null);
    }
  }

  @override
  Future<BuyerHiveModel?> getCurrentBuyer(String buyerId) async {
    try {
      final buyer = await _hiveService.getCurrentBuyer(buyerId);
      return Future.value(buyer);
    } catch (e) {
      return Future.value(null);
    }
  }

  @override
  Future<bool> isEmailExists(String email) async {
    try {
      final isExists = await _hiveService.isEmailExists(email);
      return Future.value(isExists);
    } catch (e) {
      return Future.value(false);
    }
  }

  @override
  Future<bool> isUsernameExists(String username) async {
    try {
      final isExists = await _hiveService.isUsernameExists(username);
      return Future.value(isExists);
    } catch (e) {
      return Future.value(false);
    }
  }

  @override
  Future<bool> isPhoneNumberExists(String phoneNumber) async {
    try {
      final isExists = await _hiveService.isPhoneNumberExists(phoneNumber);
      return Future.value(isExists);
    } catch (e) {
      return Future.value(false);
    }
  }
}
