// lib/features/product_condition/data/datasources/product_condition_datasource.dart
import 'package:leelame/features/product_condition/data/models/product_condition_api_model.dart';
import 'package:leelame/features/product_condition/data/models/product_condition_hive_model.dart';

abstract interface class IProductConditionLocalDatasource {
  Future<ProductConditionHiveModel?> createProductCondition(
    ProductConditionHiveModel productConditionModel,
  );
  Future<ProductConditionHiveModel?> updateProductCondition(
    ProductConditionHiveModel productConditionModel,
  );
  Future<ProductConditionHiveModel?> getProductConditionById(
    String productConditionId,
  );
  Future<ProductConditionHiveModel?> getProductConditionByProductConditionName(
    String productConditionName,
  );
  Future<bool> deleteProductCondition(String productConditionId);
  Future<List<ProductConditionHiveModel>> getAllProductConditions();
}

abstract interface class IProductConditionRemoteDatasource {
  Future<ProductConditionApiModel?> createProductCondition(
    ProductConditionApiModel productConditionModel,
  );
  Future<ProductConditionApiModel?> updateProductCondition(
    ProductConditionApiModel productConditionModel,
  );
  Future<ProductConditionApiModel?> getProductConditionById(
    String productConditionId,
  );
  Future<bool> deleteProductCondition(String productConditionId);
  Future<List<ProductConditionApiModel>> getAllProductConditions();
}
