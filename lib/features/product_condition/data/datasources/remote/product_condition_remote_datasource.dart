// lib/features/product_condition/data/datasources/remote/product_condition_remote_datasource.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/api/api_client.dart';
import 'package:leelame/core/api/api_endpoints.dart';
import 'package:leelame/core/services/storage/token_service.dart';
import 'package:leelame/features/product_condition/data/datasources/product_condition_datasource.dart';
import 'package:leelame/features/product_condition/data/models/product_condition_api_model.dart';

final productConditionRemoteDatasourceProvider =
    Provider<IProductConditionRemoteDatasource>((ref) {
      final apiClient = ref.read(apiClientProvider);
      final tokenService = ref.read(tokenServiceProvider);

      return ProductConditionRemoteDatasource(
        apiClient: apiClient,
        tokenService: tokenService,
      );
    });

class ProductConditionRemoteDatasource
    implements IProductConditionRemoteDatasource {
  final ApiClient _apiClient;
  final TokenService _tokenService;

  ProductConditionRemoteDatasource({
    required ApiClient apiClient,
    required TokenService tokenService,
  }) : _apiClient = apiClient,
       _tokenService = tokenService;

  @override
  Future<ProductConditionApiModel?> createProductCondition(
    ProductConditionApiModel productConditionModel,
  ) async {
    final token = _tokenService.getToken();
    final response = await _apiClient.post(
      ApiEndpoints.createProductCondition,
      data: productConditionModel.toJson(),
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
    final success = response.data["success"] as bool;
    final data = response.data["data"] as Map<String, dynamic>?;

    if (!success || data == null) {
      return null;
    }

    final newProductCondition = ProductConditionApiModel.fromJson(data);
    return newProductCondition;
  }

  @override
  Future<ProductConditionApiModel?> updateProductCondition(
    ProductConditionApiModel productConditionModel,
  ) async {
    final token = _tokenService.getToken();
    final response = await _apiClient.post(
      ApiEndpoints.updateProductCondition(productConditionModel.id!),
      data: productConditionModel.toJson(),
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
    final success = response.data["success"] as bool;
    final data = response.data["data"] as Map<String, dynamic>?;

    if (!success || data == null) {
      return null;
    }

    final updatedProductCondition = ProductConditionApiModel.fromJson(data);
    return updatedProductCondition;
  }

  @override
  Future<bool> deleteProductCondition(String productConditionId) async {
    final token = _tokenService.getToken();
    final response = await _apiClient.post(
      ApiEndpoints.deleteProductCondition(productConditionId),
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
    final success = response.data["success"] as bool;
    return success;
  }

  @override
  Future<ProductConditionApiModel?> getProductConditionById(
    String productConditionId,
  ) async {
    final token = _tokenService.getToken();
    final response = await _apiClient.post(
      ApiEndpoints.productConditionById(productConditionId),
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
    final success = response.data["success"] as bool;
    final data = response.data["data"] as Map<String, dynamic>?;

    if (!success || data == null) {
      return null;
    }

    final updatedProductCondition = ProductConditionApiModel.fromJson(data);
    return updatedProductCondition;
  }

  @override
  Future<List<ProductConditionApiModel>> getAllProductConditions() async {
    final response = await _apiClient.get(ApiEndpoints.getAllProductConditions);
    final success = response.data["success"] as bool;
    final data = response.data["data"] as List<Map<String, dynamic>>?;

    if (!success || data == null) {
      return [];
    }

    final productConditions = ProductConditionApiModel.fromJsonList(data);
    return productConditions;
  }
}
