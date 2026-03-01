// lib/features/product/data/datasources/product_datasource.dart
import 'dart:io';
import 'package:leelame/features/product/data/models/product_api_model.dart';
import 'package:leelame/features/product/data/models/product_hive_model.dart';

abstract interface class IProductLocalDatasource {
  Future<ProductHiveModel?> createProduct(ProductHiveModel productModel);
  Future<ProductHiveModel?> updateProduct(ProductHiveModel productModel);
  Future<ProductHiveModel?> getProductById(String productId);
  Future<bool> deleteProduct(String productId);
  Future<List<ProductHiveModel>> getAllProducts();
  Future<List<ProductHiveModel>> getAllProductsByBuyerId(String buyerId);
  Future<List<ProductHiveModel>> getAllProductsBySellerId(String sellerId);
}

abstract interface class IProductRemoteDatasource {
  Future<ProductApiModel?> createProduct(
    ProductApiModel productModel,
    List<File>? productImages,
    String? imageSubFolder,
  );
  Future<ProductApiModel?> updateProduct(
    ProductApiModel productModel,
    List<File>? productImages,
    String? imageSubFolder,
  );
  Future<ProductApiModel?> getProductById(String productId);
  Future<bool> deleteProduct(String productId);
  Future<List<ProductApiModel>> getAllProducts();
  Future<List<ProductApiModel>> getAllProductsByBuyerId(String buyerId);
  Future<List<ProductApiModel>> getAllProductsBySellerId(String sellerId);
}
