// lib/features/product_condition/data/repositories/product_condition_repository.dart
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/core/services/connectivity/network_info.dart';
import 'package:leelame/features/product_condition/data/datasources/local/product_condition_local_datasource.dart';
import 'package:leelame/features/product_condition/data/datasources/product_condition_datasource.dart';
import 'package:leelame/features/product_condition/data/datasources/remote/product_condition_remote_datasource.dart';
import 'package:leelame/features/product_condition/data/models/product_condition_api_model.dart';
import 'package:leelame/features/product_condition/data/models/product_condition_hive_model.dart';
import 'package:leelame/features/product_condition/domain/entities/product_condition_entity.dart';
import 'package:leelame/features/product_condition/domain/repositories/product_condition_repository.dart';

final productConditionRepositoryProvider =
    Provider<IProductConditionRepository>((ref) {
      final productConditionLocalDatasource = ref.read(
        productConditionLocalDatasourceProvider,
      );
      final productConditionRemoteDatasource = ref.read(
        productConditionRemoteDatasourceProvider,
      );
      final networkInfo = ref.read(networkInfoProvider);

      return ProductConditionRepository(
        productConditionLocalDatasource: productConditionLocalDatasource,
        productConditionRemoteDatasource: productConditionRemoteDatasource,
        networkInfo: networkInfo,
      );
    });

class ProductConditionRepository implements IProductConditionRepository {
  final IProductConditionLocalDatasource _productConditionLocalDatasource;
  final IProductConditionRemoteDatasource _productConditionRemoteDatasource;
  final INetworkInfo _networkInfo;

  ProductConditionRepository({
    required IProductConditionLocalDatasource productConditionLocalDatasource,
    required IProductConditionRemoteDatasource productConditionRemoteDatasource,
    required INetworkInfo networkInfo,
  }) : _productConditionLocalDatasource = productConditionLocalDatasource,
       _productConditionRemoteDatasource = productConditionRemoteDatasource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failures, ProductConditionEntity>> createProductCondition(
    ProductConditionEntity productConditionEntity,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final productConditionApiModel = ProductConditionApiModel.fromEntity(
          productConditionEntity,
        );

        final result = await _productConditionRemoteDatasource
            .createProductCondition(productConditionApiModel);
        if (result == null) {
          return const Left(
            ApiFailure(message: "Failed to create product condition!"),
          );
        }

        return Right(result.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message:
                e.response?.data["message"] ??
                "Failed to create product condition!",
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final productConditionHiveModel = ProductConditionHiveModel.fromEntity(
          productConditionEntity,
        );
        final existingProductConditionByProductConditionName =
            await _productConditionLocalDatasource
                .getProductConditionByProductConditionName(
                  productConditionEntity.productConditionName,
                );

        if (existingProductConditionByProductConditionName != null) {
          return Left(
            LocalDatabaseFailure(message: "Product condition already exists!"),
          );
        }

        final newProductCondition = await _productConditionLocalDatasource
            .createProductCondition(productConditionHiveModel);
        if (newProductCondition == null) {
          return Left(
            LocalDatabaseFailure(message: "Product condition is not created!"),
          );
        }

        return Right(newProductCondition.toEntity());
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failures, ProductConditionEntity>> updateProductCondition(
    ProductConditionEntity productConditionEntity,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final productConditionApiModel = ProductConditionApiModel.fromEntity(
          productConditionEntity,
        );

        final result = await _productConditionRemoteDatasource
            .updateProductCondition(productConditionApiModel);
        if (result == null) {
          return const Left(
            ApiFailure(message: "Failed to update product condition!"),
          );
        }

        return Right(result.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message:
                e.response?.data["message"] ??
                "Failed to update product condition!",
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final productConditionHiveModel = ProductConditionHiveModel.fromEntity(
          productConditionEntity,
        );

        final existingProductConditionById =
            await _productConditionLocalDatasource.getProductConditionById(
              productConditionEntity.productConditionId!,
            );
        if (existingProductConditionById == null) {
          return Left(
            LocalDatabaseFailure(
              message:
                  "Product condition with the product condition id not found!",
            ),
          );
        }

        final existingProductConditionByProductConditionName =
            await _productConditionLocalDatasource
                .getProductConditionByProductConditionName(
                  productConditionEntity.productConditionName,
                );

        if ((existingProductConditionByProductConditionName != null) &&
            (existingProductConditionByProductConditionName
                    .productConditionId !=
                productConditionEntity.productConditionId)) {
          return Left(
            LocalDatabaseFailure(message: "Product condition already exists!"),
          );
        }

        final updatedProductCondition = await _productConditionLocalDatasource
            .createProductCondition(productConditionHiveModel);
        if (updatedProductCondition == null) {
          return Left(
            LocalDatabaseFailure(message: "Product condition is not updated!"),
          );
        }

        return Right(updatedProductCondition.toEntity());
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failures, bool>> deleteProductCondition(
    String productConditionId,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _productConditionRemoteDatasource
            .deleteProductCondition(productConditionId);
        if (!result) {
          return const Left(
            ApiFailure(message: "Failed to delete product condition!"),
          );
        }

        return Right(result);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message:
                e.response?.data["message"] ??
                "Failed to delete product condition!",
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final result = await _productConditionLocalDatasource
            .deleteProductCondition(productConditionId);
        if (!result) {
          return const Left(
            LocalDatabaseFailure(message: "Product condition is not deleted!"),
          );
        }

        return Right(result);
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failures, ProductConditionEntity>> getProductConditionById(
    String productConditionId,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _productConditionRemoteDatasource
            .getProductConditionById(productConditionId);
        if (result == null) {
          return const Left(
            ApiFailure(message: "Failed! Product condition not found by id."),
          );
        }

        return Right(result.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message:
                e.response?.data["message"] ??
                "Failed to get the product condition by id!",
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final result = await _productConditionLocalDatasource
            .getProductConditionById(productConditionId);
        if (result == null) {
          return const Left(
            LocalDatabaseFailure(
              message: "Product condition with this id not found!",
            ),
          );
        }

        return Right(result.toEntity());
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failures, List<ProductConditionEntity>>>
  getAllProductConditions() async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _productConditionRemoteDatasource
            .getAllProductConditions();
        if (result.isEmpty) {
          return Left(
            ApiFailure(message: "Failed to fetch all product conditions!"),
          );
        }

        final productConditions = ProductConditionApiModel.toEntityList(result);

        return Right(productConditions);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message:
                e.response?.data["message"] ??
                "Failed to fetch all product conditions!",
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final result = await _productConditionLocalDatasource
            .getAllProductConditions();
        if (result.isEmpty) {
          return Left(
            LocalDatabaseFailure(
              message: "Failed to fetch all product conditions!",
            ),
          );
        }

        final productConditions = ProductConditionHiveModel.toEntityList(
          result,
        );
        return Right(productConditions);
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }
}
