// lib/features/category/domain/repositories/category_repository.dart
import 'package:dartz/dartz.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/features/category/domain/entities/category_entity.dart';

abstract interface class ICategoryRepository {
  Future<Either<Failures, CategoryEntity>> createCategory(
    CategoryEntity categoryEntity,
  );
  Future<Either<Failures, CategoryEntity>> updateCategory(
    CategoryEntity categoryEntity,
  );
  Future<Either<Failures, CategoryEntity>> getCategoryById(String categoryId);
  Future<Either<Failures, bool>> deleteCategory(String categoryId);
  Future<Either<Failures, List<CategoryEntity>>> getAllCategories();
}
