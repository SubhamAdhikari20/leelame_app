// lib/features/products/domain/repositories/product_repository.dart
import 'package:dartz/dartz.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/features/products/domain/entities/product_entity.dart';

abstract interface class IProductRepository {
  Future<Either<Failures, ProductEntity>> createProduct(
    ProductEntity productEntity,
  );
  Future<Either<Failures, ProductEntity>> updateProduct(
    ProductEntity productEntity,
  );
  Future<Either<Failures, ProductEntity>> getProductById(String productId);
  Future<Either<Failures, bool>> deleteProduct(String productId);
  Future<Either<Failures, List<ProductEntity>>> getAllProducts();
}
