// lib/features/auth/data/datasources/remote/seller_auth_remote_datasource.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/api/api_client.dart';
import 'package:leelame/core/api/api_endpoints.dart';
import 'package:leelame/features/auth/data/datasources/seller_auth_datasource.dart';
import 'package:leelame/features/auth/data/models/user_api_model.dart';
import 'package:leelame/features/seller/data/models/seller_api_model.dart';

final sellerAuthRemoteDatasourceProvider =
    Provider<ISellerAuthRemoteDatasource>((ref) {
      final apiClient = ref.read(apiClientProvider);
      return SellerAuthRemoteDatasource(apiClient: apiClient);
    });

class SellerAuthRemoteDatasource implements ISellerAuthRemoteDatasource {
  final ApiClient _apiClient;

  SellerAuthRemoteDatasource({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<SellerApiModel?> signUp(
    UserApiModel userModel,
    SellerApiModel sellerModel,
  ) async {
    final body = {
      ...sellerModel.toJson(),
      "email": userModel.email,
      "role": userModel.role,
    };
    final response = await _apiClient.post(
      ApiEndpoints.sellerSignUp,
      data: body,
    );

    if (!(response.data["success"] as bool)) {
      return null;
    }

    final data = response.data["user"] as Map<String, dynamic>;
    final newSeller = SellerApiModel.fromJson(data);
    return newSeller;
  }

  @override
  Future<bool> verifyAccountRegistration(String email, String otp) async {
    final response = await _apiClient.put(
      ApiEndpoints.sellerVerifyAccountRegistration,
      data: {"email": email, "otp": otp},
    );
    return response.data["success"] as bool;
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

    if (!(response.data["success"] as bool)) {
      return null;
    }

    final data = response.data["user"] as Map<String, dynamic>;
    final seller = SellerApiModel.fromJson(data);
    return seller;
  }

  @override
  Future<bool> logout() async {
    final response = await _apiClient.get(ApiEndpoints.sellerLogout);
    return response.data["success"] as bool;
  }

  @override
  Future<SellerApiModel?> getCurrentSeller(String sellerId) async {
    final response = await _apiClient.get(ApiEndpoints.sellerById(sellerId));
    if (!(response.data["success"] as bool)) {
      return null;
    }

    final data = response.data["data"] as Map<String, dynamic>;
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
    return response.data["success"] as bool;
  }
}
