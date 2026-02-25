// lib/features/product/data/datasources/remote/product_remote_datasource.dart
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/api/api_client.dart';
import 'package:leelame/core/api/api_endpoints.dart';
import 'package:leelame/core/services/storage/token_service.dart';
import 'package:leelame/features/product/data/datasources/product_datasource.dart';
import 'package:leelame/features/product/data/models/product_api_model.dart';

final productRemoteDatasourceProvider = Provider<IProductRemoteDatasource>((
  ref,
) {
  return ProductRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

class ProductRemoteDatasource implements IProductRemoteDatasource {
  final ApiClient _apiClient;
  final TokenService _tokenService;

  ProductRemoteDatasource({
    required ApiClient apiClient,
    required TokenService tokenService,
  }) : _apiClient = apiClient,
       _tokenService = tokenService;

  @override
  Future<ProductApiModel?> createProduct(
    ProductApiModel productModel,
    List<File>? productImages,
    String? imageSubFolder,
  ) async {
    final token = _tokenService.getToken();
    final authHeader = {"Authorization": "Bearer $token"};

    if (productImages != null && productImages.isNotEmpty) {
      final List<MultipartFile> multipartFiles = <MultipartFile>[];
      for (final file in productImages) {
        final filename = file.path.split(Platform.pathSeparator).last;
        final multipartFile = await MultipartFile.fromFile(
          file.path,
          filename: filename,
        );
        multipartFiles.add(multipartFile);
      }

      // final List<MultipartFile> multipartFiles = await Future.wait(
      //   productImages.map((file) async {
      //     final filename = file.path.split(Platform.pathSeparator).last;
      //     return MultipartFile.fromFile(file.path, filename: filename);
      //   }),
      // );

      final Map<String, dynamic> formMap = {
        "product-images": multipartFiles,
        "folder": imageSubFolder ?? "product-images",
        "productData": jsonEncode(productModel.toJson()),
      };
      final productFormData = FormData.fromMap(formMap);

      final response = await _apiClient.post(
        ApiEndpoints.createProduct,
        data: productFormData,
        options: Options(
          headers: {...authHeader, "Content-Type": "multipart/form-data"},
        ),
      );

      final success = response.data["success"] as bool;
      final data = response.data["data"] as Map<String, dynamic>?;

      if (!success || data == null) {
        return null;
      }

      final newProduct = ProductApiModel.fromJson(data);
      return newProduct;
    }

    final response = await _apiClient.post(
      ApiEndpoints.createProduct,
      data: productModel.toJson(),
      options: Options(headers: authHeader),
    );
    final success = response.data["success"] as bool;
    final data = response.data["data"] as Map<String, dynamic>?;

    if (!success || data == null) {
      return null;
    }

    final newProduct = ProductApiModel.fromJson(data);
    return newProduct;
  }

  @override
  Future<ProductApiModel?> updateProduct(
    ProductApiModel productModel,
    List<File>? productImages,
    String? imageSubFolder,
  ) async {
    final token = _tokenService.getToken();
    final authHeader = {"Authorization": "Bearer $token"};

    final hasNewImages = productImages != null && productImages.isNotEmpty;
    final hasExisitingImagesRemovals =
        productModel.removedExistingProductImageUrls != null &&
        productModel.removedExistingProductImageUrls!.isNotEmpty;

    if (hasNewImages || hasExisitingImagesRemovals) {
      final formMap = <String, dynamic>{
        "folder": imageSubFolder ?? "product-images",
        "productData": jsonEncode(productModel.toJson()),
      };

      // final productFormData = FormData();
      // productFormData.fields.add(
      //   MapEntry("productData", jsonEncode(productModel.toJson())),
      // );

      // productFormData.fields.add(
      //   MapEntry("folder", imageSubFolder ?? "product-images"),
      // );

      if (hasNewImages) {
        final List<MultipartFile> multipartFiles = <MultipartFile>[];
        for (final file in productImages) {
          final filename = file.path.split(Platform.pathSeparator).last;
          final multipartFile = await MultipartFile.fromFile(
            file.path,
            filename: filename,
          );
          multipartFiles.add(multipartFile);
          // productFormData.files.add(MapEntry("product-images", multipartFile));
        }
        formMap["product-images"] = multipartFiles;
        // productFormData.files.addAll(multipartFiles.map((file) => MapEntry("product-images", file)));
      }

      final productFormData = FormData.fromMap(formMap);

      final response = await _apiClient.put(
        ApiEndpoints.updateProduct(productModel.id!),
        data: productFormData,
        options: Options(
          headers: {...authHeader, "Content-Type": "multipart/form-data"},
        ),
      );

      final success = response.data["success"] as bool;
      final data = response.data["data"] as Map<String, dynamic>?;

      if (!success || data == null) {
        return null;
      }

      final updatedProduct = ProductApiModel.fromJson(data);
      return updatedProduct;
    }

    final response = await _apiClient.put(
      ApiEndpoints.updateProduct(productModel.id!),
      data: productModel.toJson(),
      options: Options(headers: authHeader),
    );
    final success = response.data["success"] as bool;
    final data = response.data["data"] as Map<String, dynamic>?;

    if (!success || data == null) {
      return null;
    }

    final updatedProduct = ProductApiModel.fromJson(data);
    return updatedProduct;
  }

  @override
  Future<bool> deleteProduct(String productId) async {
    final token = _tokenService.getToken();
    final response = await _apiClient.post(
      ApiEndpoints.deleteProduct(productId),
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
    final success = response.data["success"] as bool;
    return success;
  }

  @override
  Future<ProductApiModel?> getProductById(String productId) async {
    final token = _tokenService.getToken();
    final response = await _apiClient.post(
      ApiEndpoints.productById(productId),
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
    final success = response.data["success"] as bool;
    final data = response.data["data"] as Map<String, dynamic>?;

    if (!success || data == null) {
      return null;
    }

    final updatedProduct = ProductApiModel.fromJson(data);
    return updatedProduct;
  }

  @override
  Future<List<ProductApiModel>> getAllProducts() async {
    final response = await _apiClient.get(ApiEndpoints.getAllProducts);
    final success = response.data["success"] as bool;
    final data = response.data["data"] as List<Map<String, dynamic>>?;

    if (!success || data == null) {
      return [];
    }

    final products = ProductApiModel.fromJsonList(data);
    return products;
  }

  @override
  Future<List<ProductApiModel>> getAllProductsByBuyerId(String buyerId) async {
    final response = await _apiClient.get(
      ApiEndpoints.getAllProductsByBuyerId(buyerId),
    );
    final success = response.data["success"] as bool;
    final data = response.data["data"] as List<Map<String, dynamic>>?;

    if (!success || data == null) {
      return [];
    }

    final products = ProductApiModel.fromJsonList(data);
    return products;
  }
}
