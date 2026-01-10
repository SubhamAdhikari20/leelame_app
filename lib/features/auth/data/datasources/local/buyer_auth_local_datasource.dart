// lib/features/auth/data/datasources/local/buyer_auth_local_datasource.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/services/hive/hive_service.dart';
import 'package:leelame/core/services/storage/user_session_service.dart';
import 'package:leelame/features/auth/data/datasources/buyer_auth_datasource.dart';
import 'package:leelame/features/auth/data/models/user_hive_model.dart';
import 'package:leelame/features/buyer/data/models/buyer_hive_model.dart';

final buyerAuthLocalDatasourceProvider = Provider<IBuyerAuthDatasource>((ref) {
  final hiveService = ref.read(hiveServiceProvider);
  final userSessionService = ref.read(userSessionServiceProvider);
  return BuyerAuthLocalDatasource(
    hiveService: hiveService,
    userSessionService: userSessionService,
  );
});

class BuyerAuthLocalDatasource implements IBuyerAuthDatasource {
  final HiveService _hiveService;
  final UserSessionService _userSessionService;

  BuyerAuthLocalDatasource({
    required HiveService hiveService,
    required UserSessionService userSessionService,
  }) : _hiveService = hiveService,
       _userSessionService = userSessionService;

  @override
  Future<BuyerHiveModel?> login(
    String identifier,
    String password,
    String role,
  ) async {
    try {
      final buyer = await _hiveService.loginBuyer(identifier, password, role);
      if (buyer != null) {
        final baseUser = await _hiveService.getUserById(buyer.userId!);
        if (baseUser != null) {
          await _userSessionService.storeUserSession(
            userId: buyer.buyerId!,
            email: baseUser.email,
            role: baseUser.role,
            fullName: buyer.fullName,
            username: buyer.username,
            phoneNumber: buyer.phoneNumber,
            profilePictureUrl: buyer.profilePictureUrl,
          );
        }
      }
      return Future.value(buyer);
    } catch (e) {
      return Future.value(null);
    }
  }

  @override
  Future<bool> logout() async {
    try {
      final isLoggedOut = await _hiveService.logoutBuyer();

      if (isLoggedOut) {
        await _userSessionService.clearUserSession();
      }

      return Future.value(isLoggedOut);
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
