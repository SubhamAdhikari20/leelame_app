// lib/features/product/domain/repositories/product_repository.dart
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/features/product/domain/entities/product_entity.dart';

abstract interface class IProductRepository {
  Future<Either<Failures, ProductEntity>> createProduct(
    ProductEntity productEntity,
    List<File>? productImages,
    String? imageSubFolder,
  );
  Future<Either<Failures, ProductEntity>> updateProduct(
    ProductEntity productEntity,
    List<File>? productImages,
    String? imageSubFolder,
  );
  Future<Either<Failures, ProductEntity>> getProductById(String productId);
  Future<Either<Failures, bool>> deleteProduct(String productId);
  Future<Either<Failures, List<ProductEntity>>> getAllProducts();
  Future<Either<Failures, List<ProductEntity>>> getAllProductsByBuyerId(
    String buyerId,
  );
  Future<Either<Failures, List<ProductEntity>>> getAllProductsBySellerId(
    String sellerId,
  );
}
