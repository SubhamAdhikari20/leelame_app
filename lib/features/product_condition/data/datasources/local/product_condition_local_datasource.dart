// lib/features/product_condition/data/datasources/local/product_condition_local_datasource.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/services/hive/hive_service.dart';
import 'package:leelame/features/product_condition/data/datasources/product_condition_datasource.dart';
import 'package:leelame/features/product_condition/data/models/product_condition_hive_model.dart';

final productConditionLocalDatasourceProvider =
    Provider<IProductConditionLocalDatasource>((ref) {
      final hiveService = ref.read(hiveServiceProvider);
      return ProductConditionLocalDatasource(hiveService: hiveService);
    });

class ProductConditionLocalDatasource
    implements IProductConditionLocalDatasource {
  final HiveService _hiveService;

  ProductConditionLocalDatasource({required HiveService hiveService})
    : _hiveService = hiveService;

  @override
  Future<ProductConditionHiveModel?> createProductCondition(
    ProductConditionHiveModel productConditionModel,
  ) async {
    final result = await _hiveService.createProductCondition(
      productConditionModel,
    );
    return Future.value(result);
  }

  @override
  Future<ProductConditionHiveModel?> updateProductCondition(
    ProductConditionHiveModel productConditionModel,
  ) async {
    final result = await _hiveService.updateProductCondition(
      productConditionModel,
    );
    return Future.value(result);
  }

  @override
  Future<bool> deleteProductCondition(String productConditionId) async {
    final result = await _hiveService.deleteProductCondition(
      productConditionId,
    );
    return Future.value(result);
  }

  @override
  Future<ProductConditionHiveModel?> getProductConditionById(
    String productConditionId,
  ) async {
    final result = await _hiveService.getProductConditionById(
      productConditionId,
    );
    return Future.value(result);
  }

  @override
  Future<ProductConditionHiveModel?> getProductConditionByProductConditionName(
    String productConditionName,
  ) async {
    final result = await _hiveService.getProductConditionByProductConditionName(
      productConditionName,
    );
    return Future.value(result);
  }

  @override
  Future<List<ProductConditionHiveModel>> getAllProductConditions() async {
    final result = await _hiveService.getAllProductConditions();
    return Future.value(result);
  }
}
