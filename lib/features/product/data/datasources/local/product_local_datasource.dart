// lib/features/product/data/datasources/local/product_local_datasource.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/services/hive/hive_service.dart';
import 'package:leelame/features/product/data/datasources/product_datasource.dart';
import 'package:leelame/features/product/data/models/product_hive_model.dart';

final productLocalDatasourceProvider = Provider<IProductLocalDatasource>((ref) {
  final hiveService = ref.read(hiveServiceProvider);
  return ProductLocalDatasource(hiveService: hiveService);
});

class ProductLocalDatasource implements IProductLocalDatasource {
  final HiveService _hiveService;

  ProductLocalDatasource({required HiveService hiveService})
    : _hiveService = hiveService;

  @override
  Future<ProductHiveModel?> createProduct(ProductHiveModel productModel) async {
    final result = await _hiveService.createProduct(productModel);
    return Future.value(result);
  }

  @override
  Future<ProductHiveModel?> updateProduct(ProductHiveModel productModel) async {
    final result = await _hiveService.updateProduct(productModel);
    return Future.value(result);
  }

  @override
  Future<bool> deleteProduct(String productId) async {
    final result = await _hiveService.deleteProduct(productId);
    return Future.value(result);
  }

  @override
  Future<ProductHiveModel?> getProductById(String productId) async {
    final result = await _hiveService.getProductById(productId);
    return Future.value(result);
  }

  @override
  Future<List<ProductHiveModel>> getAllProducts() async {
    final result = await _hiveService.getAllProducts();
    return Future.value(result);
  }

  @override
  Future<List<ProductHiveModel>> getAllProductsByBuyerId(String buyerId) async {
    final result = await _hiveService.getAllProductsByBuyerId(buyerId);
    return Future.value(result);
  }

  @override
  Future<List<ProductHiveModel>> getAllProductsBySellerId(
    String sellerId,
  ) async {
    final result = await _hiveService.getAllProductsBySellerId(sellerId);
    return Future.value(result);
  }
}
