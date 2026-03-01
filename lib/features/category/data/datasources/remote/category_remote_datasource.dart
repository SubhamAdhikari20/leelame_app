// lib/features/category/data/datasources/remote/category_remote_datasource.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/api/api_client.dart';
import 'package:leelame/core/api/api_endpoints.dart';
import 'package:leelame/core/services/storage/token_service.dart';
import 'package:leelame/features/category/data/datasources/category_datasource.dart';
import 'package:leelame/features/category/data/models/category_api_model.dart';

final categoryRemoteDatasourceProvider = Provider<ICategoryRemoteDatasource>((
  ref,
) {
  final apiClient = ref.read(apiClientProvider);
  final tokenService = ref.read(tokenServiceProvider);
  return CategoryRemoteDatasource(
    apiClient: apiClient,
    tokenService: tokenService,
  );
});

class CategoryRemoteDatasource implements ICategoryRemoteDatasource {
  final ApiClient _apiClient;
  final TokenService _tokenService;

  CategoryRemoteDatasource({
    required ApiClient apiClient,
    required TokenService tokenService,
  }) : _apiClient = apiClient,
       _tokenService = tokenService;

  @override
  Future<CategoryApiModel?> createCategory(
    CategoryApiModel categoryModel,
  ) async {
    final token = _tokenService.getToken();
    final response = await _apiClient.post(
      ApiEndpoints.createCategory,
      data: categoryModel.toJson(),
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
    final success = response.data["success"] as bool;
    final data = response.data["data"] as Map<String, dynamic>?;

    if (!success || data == null) {
      return null;
    }

    final newCategory = CategoryApiModel.fromJson(data);
    return newCategory;
  }

  @override
  Future<CategoryApiModel?> updateCategory(
    CategoryApiModel categoryModel,
  ) async {
    final token = _tokenService.getToken();
    final response = await _apiClient.post(
      ApiEndpoints.updateCategory(categoryModel.id!),
      data: categoryModel.toJson(),
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
    final success = response.data["success"] as bool;
    final data = response.data["data"] as Map<String, dynamic>?;

    if (!success || data == null) {
      return null;
    }

    final updatedCategory = CategoryApiModel.fromJson(data);
    return updatedCategory;
  }

  @override
  Future<bool> deleteCategory(String categoryId) async {
    final token = _tokenService.getToken();
    final response = await _apiClient.post(
      ApiEndpoints.deleteCategory(categoryId),
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
    final success = response.data["success"] as bool;
    return success;
  }

  @override
  Future<CategoryApiModel?> getCategoryById(String categoryId) async {
    // final token = _tokenService.getToken();
    final response = await _apiClient.get(
      ApiEndpoints.categoryById(categoryId),
      // options: Options(headers: {"Authorization": "Bearer $token"}),
    );
    final success = response.data["success"] as bool;
    final data = response.data["data"] as Map<String, dynamic>?;

    if (!success || data == null) {
      return null;
    }

    final updatedCategory = CategoryApiModel.fromJson(data);
    return updatedCategory;
  }

  @override
  Future<List<CategoryApiModel>> getAllCategories() async {
    final response = await _apiClient.get(ApiEndpoints.getAllCategories);
    final success = response.data["success"] as bool;
    final data = response.data["data"] as List<dynamic>?;
    // final data = response.data["data"] as List<Map<String, dynamic>>?;

    if (!success || data == null) {
      return [];
    }

    final categories = CategoryApiModel.fromJsonList(data);
    return categories;
  }
}
