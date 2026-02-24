// lib/features/product_condition/domain/repositories/product_condition_repository.dart
import 'package:dartz/dartz.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/features/product_condition/domain/entities/product_condition_entity.dart';

abstract interface class IProductConditionRepository {
  Future<Either<Failures, ProductConditionEntity>> createProductCondition(
    ProductConditionEntity productConditionEntity,
  );
  Future<Either<Failures, ProductConditionEntity>> updateProductCondition(
    ProductConditionEntity productConditionEntity,
  );
  Future<Either<Failures, ProductConditionEntity>> getProductConditionById(
    String productConditionId,
  );
  Future<Either<Failures, bool>> deleteProductCondition(
    String productConditionId,
  );
  Future<Either<Failures, List<ProductConditionEntity>>>
  getAllProductConditions();
}
