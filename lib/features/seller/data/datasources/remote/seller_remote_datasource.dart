// lib/features/seller/data/datasources/remote/seller_remote_datasource.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/api/api_client.dart';
import 'package:leelame/core/api/api_endpoints.dart';
import 'package:leelame/core/services/storage/token_service.dart';
import 'package:leelame/features/seller/data/datasources/seller_datasource.dart';
import 'package:leelame/features/seller/data/models/seller_api_model.dart';

final sellerRemoteDatasourceProvider = Provider<ISellerRemoteDatasource>((ref) {
  return SellerRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

class SellerRemoteDatasource implements ISellerRemoteDatasource {
  final ApiClient _apiClient;
  final TokenService _tokenService;

  SellerRemoteDatasource({
    required ApiClient apiClient,
    required TokenService tokenService,
  }) : _apiClient = apiClient,
       _tokenService = tokenService;

  @override
  Future<SellerApiModel?> getCurrentSeller(String sellerId) async {
    final token = _tokenService.getToken();
    final response = await _apiClient.get(
      ApiEndpoints.currentSeller(sellerId),
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
  Future<SellerApiModel?> updateSeller(SellerApiModel sellerApiModel) async {
    final token = _tokenService.getToken();
    final body = sellerApiModel.toJson(userApiModel: sellerApiModel.baseUser);
    final response = await _apiClient.put(
      ApiEndpoints.sellerUpdateById(sellerApiModel.id!),
      data: body,
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );

    final success = response.data["success"] as bool;
    final data = response.data["user"] as Map<String, dynamic>?;

    if (!success || data == null) {
      return null;
    }

    final updatedSeller = SellerApiModel.fromJson(data);
    return updatedSeller;
  }

  @override
  Future<String?> uploadSellerProfilePicture(
    String sellerId,
    File profilePicture,
  ) async {
    final fileName = profilePicture.path.split("/").last;
    final formData = FormData.fromMap({
      "profile-picture-seller": await MultipartFile.fromFile(
        profilePicture.path,
        filename: fileName,
      ),
      "folder": "profile-pictures/sellers",
    });

    final token = _tokenService.getToken();
    final response = await _apiClient.uploadFile(
      ApiEndpoints.sellerUploadProfilePicture(sellerId),
      formData: formData,
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );

    final success = response.data["success"] as bool;
    final data = response.data["user"] as Map<String, dynamic>?;
    final image = data?["imageUrl"] as String?;

    if (!success || data == null || image == null) {
      return null;
    }

    final imageUrl = "${ApiEndpoints.mediaServerUrl}$image";
    return imageUrl;
    // return image;
  }

  @override
  Future<List<SellerApiModel>> getAllSellers() async {
    final response = await _apiClient.get(ApiEndpoints.getAllSellers);
    final success = response.data["success"] as bool;
    final data = response.data["users"] as List<dynamic>?;
    // final data = response.data["users"] as List<Map<String, dynamic>>?;

    if (!success || data == null) {
      return [];
    }

    final sellers = SellerApiModel.fromJsonList(data);
    return sellers;
  }

  @override
  Future<SellerApiModel?> getSellerById(String sellerId) async {
    final response = await _apiClient.get(ApiEndpoints.sellerById(sellerId));

    final success = response.data["success"] as bool;
    final data = response.data["user"] as Map<String, dynamic>?;

    if (!success || data == null) {
      return null;
    }

    final seller = SellerApiModel.fromJson(data);
    return seller;
  }
}
