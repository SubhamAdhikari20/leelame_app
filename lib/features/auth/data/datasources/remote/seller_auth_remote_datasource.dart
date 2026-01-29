// lib/features/auth/data/datasources/remote/seller_auth_remote_datasource.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/api/api_client.dart';
import 'package:leelame/core/api/api_endpoints.dart';
import 'package:leelame/core/services/storage/token_service.dart';
import 'package:leelame/features/auth/data/datasources/seller_auth_datasource.dart';
import 'package:leelame/features/auth/data/models/user_api_model.dart';
import 'package:leelame/features/seller/data/models/seller_api_model.dart';

final sellerAuthRemoteDatasourceProvider =
    Provider<ISellerAuthRemoteDatasource>((ref) {
      final apiClient = ref.read(apiClientProvider);
      final tokenService = ref.read(tokenServiceProvider);

      return SellerAuthRemoteDatasource(
        apiClient: apiClient,
        tokenService: tokenService,
      );
    });

class SellerAuthRemoteDatasource implements ISellerAuthRemoteDatasource {
  final ApiClient _apiClient;
  final TokenService _tokenService;

  SellerAuthRemoteDatasource({
    required ApiClient apiClient,
    required TokenService tokenService,
  }) : _apiClient = apiClient,
       _tokenService = tokenService;

  @override
  Future<SellerApiModel?> signUp(
    UserApiModel userModel,
    SellerApiModel sellerModel,
  ) async {
    final body = sellerModel.toJson(userApiModel: userModel);
    final response = await _apiClient.post(
      ApiEndpoints.sellerSignUp,
      data: body,
    );

    final success = response.data["success"] as bool;
    final data = response.data["user"] as Map<String, dynamic>?;

    if (!success || data == null) {
      return null;
    }

    final newSeller = SellerApiModel.fromJson(data);
    return newSeller;
  }

  @override
  Future<bool> verifyAccountRegistration(String email, String otp) async {
    final response = await _apiClient.put(
      ApiEndpoints.sellerVerifyAccountRegistration,
      data: {"email": email, "otp": otp},
    );

    final success = response.data["success"] as bool;
    return success;
  }

  @override
  Future<SellerApiModel?> login(
    String identifier,
    String password,
    String role,
  ) async {
    final response = await _apiClient.post(
      ApiEndpoints.sellerLogin,
      data: {"identifier": identifier, "password": password, "role": role},
    );

    final success = response.data["success"] as bool;
    final data = response.data["user"] as Map<String, dynamic>?;
    final token = response.data["token"] as String?;

    if (!success || data == null || token == null) {
      return null;
    }

    // save token locally
    await _tokenService.saveToken(token);

    final seller = SellerApiModel.fromJson(data);
    return seller;
  }

  @override
  Future<bool> logout() async {
    final token = _tokenService.getToken();
    final response = await _apiClient.get(
      ApiEndpoints.sellerLogout,
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );

    final success = response.data["success"] as bool;
    if (!success) {
      return false;
    }

    await _tokenService.removeToken();
    return true;
  }

  @override
  Future<SellerApiModel?> getCurrentSeller(String sellerId) async {
    final token = _tokenService.getToken();
    final response = await _apiClient.get(
      ApiEndpoints.sellerById(sellerId),
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );

    final success = response.data["success"] as bool;
    final data = response.data["user"] as Map<String, dynamic>?;

    if (!success || data == null) {
      return null;
    }

    final seller = SellerApiModel.fromJson(data);
    return seller;
  }

  @override
  Future<bool> sendQueuedVerificationEmail({
    String? userId,
    required String email,
    required String otp,
    DateTime? expiry,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.sellerSendVerificationEmailRegistration,
      data: {
        "userId": userId,
        "email": email,
        "otp": otp,
        "expiry": expiry?.toIso8601String(),
      },
    );

    final success = response.data["success"] as bool;
    return success;
  }
}
