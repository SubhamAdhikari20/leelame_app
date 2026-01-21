// lib/features/auth/data/datasources/remote/buyer_auth_remote_datasource.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/api/api_client.dart';
import 'package:leelame/core/api/api_endpoints.dart';
import 'package:leelame/features/auth/data/datasources/buyer_auth_datasource.dart';
import 'package:leelame/features/auth/data/models/user_api_model.dart';
import 'package:leelame/features/buyer/data/models/buyer_api_model.dart';

final buyerAuthRemoteDatasourceProvider = Provider<IBuyerAuthRemoteDatasource>((
  ref,
) {
  final apiClient = ref.read(apiClientProvider);
  return BuyerAuthRemoteDatasource(apiClient: apiClient);
});

class BuyerAuthRemoteDatasource implements IBuyerAuthRemoteDatasource {
  final ApiClient _apiClient;

  BuyerAuthRemoteDatasource({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<BuyerApiModel?> signUp(
    UserApiModel userModel,
    BuyerApiModel buyerModel,
  ) async {
    final body = {
      ...buyerModel.toJson(),
      "email": userModel.email,
      "role": userModel.role,
      // "baseUser": userModel.toJson(),
    };
    final response = await _apiClient.post(
      ApiEndpoints.buyerSignUp,
      data: body,
    );

    if (!(response.data["success"] as bool)) {
      return null;
    }

    final data = response.data["user"] as Map<String, dynamic>;
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

    if (!(response.data["success"] as bool)) {
      return null;
    }

    final data = response.data["user"] as Map<String, dynamic>;
    final buyer = BuyerApiModel.fromJson(data);
    return buyer;
  }

  @override
  Future<bool> logout() async {
    final response = await _apiClient.get(ApiEndpoints.buyerLogout);
    if (!(response.data["success"] as bool)) {
      return false;
    }
    return true;
  }

  @override
  Future<BuyerApiModel?> getCurrentBuyer(String buyerId) async {
    final response = await _apiClient.get(ApiEndpoints.buyerById(buyerId));
    if (!(response.data["success"] as bool)) {
      return null;
    }

    final data = response.data["data"] as Map<String, dynamic>;
    final buyer = BuyerApiModel.fromJson(data);
    return buyer;
  }

  @override
  Future<UserApiModel?> getCurrentUser(String userId) async {
    final response = await _apiClient.get(ApiEndpoints.userById(userId));
    if (!(response.data["success"] as bool)) {
      return null;
    }

    final data = response.data["data"] as Map<String, dynamic>;
    final baseUser = UserApiModel.fromJson(data);
    return baseUser;
  }

  @override
  Future<bool> isEmailExists(String email) async {
    final response = await _apiClient.get(ApiEndpoints.userByEmail(email));
    return response.data["success"] as bool;
  }

  @override
  Future<bool> isPhoneNumberExists(String phoneNumber) async {
    final response = await _apiClient.get(
      ApiEndpoints.buyerByPhoneNumber(phoneNumber),
    );
    return response.data["success"] as bool;
  }

  @override
  Future<bool> isUsernameExists(String username) async {
    final response = await _apiClient.get(
      ApiEndpoints.buyerByUsername(username),
    );
    return response.data["success"] as bool;
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
    return response.data["success"] as bool;
  }
}
