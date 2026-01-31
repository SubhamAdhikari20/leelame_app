// lib/features/buyer/data/datasources/remote/buyer_remote_datasource.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/api/api_client.dart';
import 'package:leelame/core/api/api_endpoints.dart';
import 'package:leelame/core/services/storage/token_service.dart';
import 'package:leelame/features/buyer/data/datasources/buyer_datasource.dart';
import 'package:leelame/features/buyer/data/models/buyer_api_model.dart';

final buyerRemoteDatasourceProvider = Provider<IBuyerRemoteDatasource>((ref) {
  return BuyerRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

class BuyerRemoteDatasource implements IBuyerRemoteDatasource {
  final ApiClient _apiClient;
  final TokenService _tokenService;

  BuyerRemoteDatasource({
    required ApiClient apiClient,
    required TokenService tokenService,
  }) : _apiClient = apiClient,
       _tokenService = tokenService;

  @override
  Future<BuyerApiModel?> getCurrentBuyer(String buyerId) async {
    final token = _tokenService.getToken();
    final response = await _apiClient.get(
      ApiEndpoints.buyerById(buyerId),
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );

    final success = response.data["success"] as bool;
    final data = response.data["user"] as Map<String, dynamic>?;

    if (!success || data == null) {
      return null;
    }

    final buyer = BuyerApiModel.fromJson(data);
    return buyer;
  }

  @override
  Future<BuyerApiModel?> updateBuyer(BuyerApiModel buyerApiModel) async {
    final token = _tokenService.getToken();
    final body = buyerApiModel.toJson(userApiModel: buyerApiModel.baseUser);
    final response = await _apiClient.put(
      ApiEndpoints.buyerUpdateById(buyerApiModel.id!),
      data: body,
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );

    final success = response.data["success"] as bool;
    final data = response.data["user"] as Map<String, dynamic>?;

    if (!success || data == null) {
      return null;
    }

    final updatedBuyer = BuyerApiModel.fromJson(data);
    return updatedBuyer;
  }

  @override
  Future<String?> uploadBuyerProfilePicture(
    String buyerId,
    File profilePicture,
  ) async {
    final fileName = profilePicture.path.split("/").last;
    final formData = FormData.fromMap({
      "itemPhoto": await MultipartFile.fromFile(
        profilePicture.path,
        filename: fileName,
      ),
    });

    final token = _tokenService.getToken();
    final response = await _apiClient.uploadFile(
      ApiEndpoints.buyerUploadProfilePicture(buyerId),
      formData: formData,
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );

    final success = response.data["success"] as bool;
    final data = response.data["data"] as Map<String, dynamic>?;
    final imageUrl = data?["imageUrl"] as String?;

    if (!success || data == null || imageUrl == null) {
      return null;
    }

    return imageUrl;
  }
}
