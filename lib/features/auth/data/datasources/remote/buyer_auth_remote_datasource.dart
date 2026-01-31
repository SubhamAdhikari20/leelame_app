// lib/features/auth/data/datasources/remote/buyer_auth_remote_datasource.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/api/api_client.dart';
import 'package:leelame/core/api/api_endpoints.dart';
import 'package:leelame/core/services/storage/token_service.dart';
import 'package:leelame/features/auth/data/datasources/buyer_auth_datasource.dart';
import 'package:leelame/features/auth/data/models/user_api_model.dart';
import 'package:leelame/features/buyer/data/models/buyer_api_model.dart';

final buyerAuthRemoteDatasourceProvider = Provider<IBuyerAuthRemoteDatasource>((
  ref,
) {
  final apiClient = ref.read(apiClientProvider);
  final tokenService = ref.read(tokenServiceProvider);

  return BuyerAuthRemoteDatasource(
    apiClient: apiClient,
    tokenService: tokenService,
  );
});

class BuyerAuthRemoteDatasource implements IBuyerAuthRemoteDatasource {
  final ApiClient _apiClient;
  final TokenService _tokenService;

  BuyerAuthRemoteDatasource({
    required ApiClient apiClient,
    required TokenService tokenService,
  }) : _apiClient = apiClient,
       _tokenService = tokenService;

  @override
  Future<BuyerApiModel?> signUp(
    UserApiModel userModel,
    BuyerApiModel buyerModel,
  ) async {
    final body = buyerModel.toJson(userApiModel: userModel);
    final response = await _apiClient.post(
      ApiEndpoints.buyerSignUp,
      data: body,
    );

    final success = response.data["success"] as bool;
    final data = response.data["user"] as Map<String, dynamic>?;

    if (!success || data == null) {
      return null;
    }

    final newBuyer = BuyerApiModel.fromJson(data);
    return newBuyer;
  }

  @override
  Future<bool> verifyAccountRegistration(String username, String otp) async {
    final response = await _apiClient.put(
      ApiEndpoints.buyerVerifyAccountRegistration,
      data: {"username": username, "otp": otp},
    );
    return response.data["success"] as bool;
  }

  @override
  Future<BuyerApiModel?> login(
    String identifier,
    String password,
    String role,
  ) async {
    final response = await _apiClient.post(
      ApiEndpoints.buyerLogin,
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

    final buyer = BuyerApiModel.fromJson(data);
    return buyer;
  }

  @override
  Future<bool> logout() async {
    final token = _tokenService.getToken();
    final response = await _apiClient.get(
      ApiEndpoints.buyerLogout,
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
  Future<bool> sendQueuedVerificationEmail({
    String? userId,
    required String email,
    required String otp,
    DateTime? expiry,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.buyerSendVerificationEmailRegistration,
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
