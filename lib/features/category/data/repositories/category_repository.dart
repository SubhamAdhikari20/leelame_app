// lib/features/category/data/repositories/category_repository.dart
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/core/services/connectivity/network_info.dart';
import 'package:leelame/features/category/data/datasources/category_datasource.dart';
import 'package:leelame/features/category/data/datasources/local/category_local_datasource.dart';
import 'package:leelame/features/category/data/datasources/remote/category_remote_datasource.dart';
import 'package:leelame/features/category/data/models/category_api_model.dart';
import 'package:leelame/features/category/data/models/category_hive_model.dart';
import 'package:leelame/features/category/domain/entities/category_entity.dart';
import 'package:leelame/features/category/domain/repositories/category_repository.dart';

final categoryRepositoryProvider = Provider<ICategoryRepository>((ref) {
  final categoryLocalDatasource = ref.read(categoryLocalDatasourceProvider);
  final categoryRemoteDatasource = ref.read(categoryRemoteDatasourceProvider);
  final networkInfo = ref.read(networkInfoProvider);

  return CategoryRepository(
    categoryLocalDatasource: categoryLocalDatasource,
    categoryRemoteDatasource: categoryRemoteDatasource,
    networkInfo: networkInfo,
  );
});

class CategoryRepository implements ICategoryRepository {
  final ICategoryLocalDatasource _categoryLocalDatasource;
  final ICategoryRemoteDatasource _categoryRemoteDatasource;
  final INetworkInfo _networkInfo;

  CategoryRepository({
    required ICategoryLocalDatasource categoryLocalDatasource,
    required ICategoryRemoteDatasource categoryRemoteDatasource,
    required INetworkInfo networkInfo,
  }) : _categoryLocalDatasource = categoryLocalDatasource,
       _categoryRemoteDatasource = categoryRemoteDatasource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failures, CategoryEntity>> createCategory(
    CategoryEntity categoryEntity,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final categoryApiModel = CategoryApiModel.fromEntity(categoryEntity);

        final result = await _categoryRemoteDatasource.createCategory(
          categoryApiModel,
        );
        if (result == null) {
          return const Left(ApiFailure(message: "Failed to create category!"));
        }

        return Right(result.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message:
                e.response?.data["message"] ?? "Failed to create category!",
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final categoryHiveModel = CategoryHiveModel.fromEntity(categoryEntity);
        final existingCategoryByCategoryName = await _categoryLocalDatasource
            .getCategoryByCategoryName(categoryEntity.categoryName);

        if (existingCategoryByCategoryName != null) {
          return Left(
            LocalDatabaseFailure(message: "Category already exists!"),
          );
        }

        final newCategory = await _categoryLocalDatasource.createCategory(
          categoryHiveModel,
        );
        if (newCategory == null) {
          return Left(
            LocalDatabaseFailure(message: "Category is not created!"),
          );
        }

        return Right(newCategory.toEntity());
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failures, CategoryEntity>> updateCategory(
    CategoryEntity categoryEntity,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final categoryApiModel = CategoryApiModel.fromEntity(categoryEntity);

        final result = await _categoryRemoteDatasource.updateCategory(
          categoryApiModel,
        );
        if (result == null) {
          return const Left(ApiFailure(message: "Failed to update category!"));
        }

        return Right(result.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message:
                e.response?.data["message"] ?? "Failed to update category!",
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final categoryHiveModel = CategoryHiveModel.fromEntity(categoryEntity);

        final existingCategoryById = await _categoryLocalDatasource
            .getCategoryById(categoryEntity.categoryId!);
        if (existingCategoryById == null) {
          return Left(
            LocalDatabaseFailure(
              message: "Category with the category id not found!",
            ),
          );
        }

        final existingCategoryByCategoryName = await _categoryLocalDatasource
            .getCategoryByCategoryName(categoryEntity.categoryName);

        if ((existingCategoryByCategoryName != null) &&
            (existingCategoryByCategoryName.categoryId !=
                categoryEntity.categoryId)) {
          return Left(
            LocalDatabaseFailure(message: "Category already exists!"),
          );
        }

        final updatedCategory = await _categoryLocalDatasource.createCategory(
          categoryHiveModel,
        );
        if (updatedCategory == null) {
          return Left(
            LocalDatabaseFailure(message: "Category is not updated!"),
          );
        }

        return Right(updatedCategory.toEntity());
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failures, bool>> deleteCategory(String categoryId) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _categoryRemoteDatasource.deleteCategory(
          categoryId,
        );
        if (!result) {
          return const Left(ApiFailure(message: "Failed to delete category!"));
        }

        return Right(result);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message:
                e.response?.data["message"] ?? "Failed to delete category!",
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final result = await _categoryLocalDatasource.deleteCategory(
          categoryId,
        );
        if (!result) {
          return const Left(
            LocalDatabaseFailure(message: "Category is not deleted!"),
          );
        }

        return Right(result);
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failures, CategoryEntity>> getCategoryById(
    String categoryId,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _categoryRemoteDatasource.getCategoryById(
          categoryId,
        );
        if (result == null) {
          return const Left(
            ApiFailure(message: "Failed! Category not found by id."),
          );
        }

        return Right(result.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message:
                e.response?.data["message"] ??
                "Failed to get the category by id!",
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final result = await _categoryLocalDatasource.getCategoryById(
          categoryId,
        );
        if (result == null) {
          return const Left(
            LocalDatabaseFailure(message: "Category with this id not found!"),
          );
        }

        return Right(result.toEntity());
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failures, List<CategoryEntity>>> getAllCategories() async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _categoryRemoteDatasource.getAllCategories();
        if (result.isEmpty) {
          return Left(ApiFailure(message: "Failed to fetch all categories!"));
        }

        final categories = CategoryApiModel.toEntityList(result);

        return Right(categories);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message:
                e.response?.data["message"] ??
                "Failed to fetch all categories!",
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final result = await _categoryLocalDatasource.getAllCategories();
        if (result.isEmpty) {
          return Left(
            LocalDatabaseFailure(message: "Failed to fetch all categories!"),
          );
        }

        final categories = CategoryHiveModel.toEntityList(result);
        return Right(categories);
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }
}
