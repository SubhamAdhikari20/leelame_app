// lib/features/product/data/repositories/product_repository.dart
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/core/services/connectivity/network_info.dart';
import 'package:leelame/core/utils/http_url_util.dart';
import 'package:leelame/features/product/data/datasources/local/product_local_datasource.dart';
import 'package:leelame/features/product/data/datasources/product_datasource.dart';
import 'package:leelame/features/product/data/datasources/remote/product_remote_datasource.dart';
import 'package:leelame/features/product/data/models/product_api_model.dart';
import 'package:leelame/features/product/data/models/product_hive_model.dart';
import 'package:leelame/features/product/domain/entities/product_entity.dart';
import 'package:leelame/features/product/domain/repositories/product_repository.dart';

final productRepositoryProvider = Provider<IProductRepository>((ref) {
  final productLocalDatasource = ref.read(productLocalDatasourceProvider);
  final productRemoteDatasource = ref.read(productRemoteDatasourceProvider);
  final networkInfo = ref.read(networkInfoProvider);

  return ProductRepository(
    productLocalDatasource: productLocalDatasource,
    productRemoteDatasource: productRemoteDatasource,
    networkInfo: networkInfo,
  );
});

class ProductRepository implements IProductRepository {
  final IProductLocalDatasource _productLocalDatasource;
  final IProductRemoteDatasource _productRemoteDatasource;
  final INetworkInfo _networkInfo;

  ProductRepository({
    required IProductLocalDatasource productLocalDatasource,
    required IProductRemoteDatasource productRemoteDatasource,
    required INetworkInfo networkInfo,
  }) : _productLocalDatasource = productLocalDatasource,
       _productRemoteDatasource = productRemoteDatasource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failures, ProductEntity>> createProduct(
    ProductEntity productEntity,
    List<File>? productImages,
    String? imageSubFolder,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final productApiModel = ProductApiModel.fromEntity(productEntity);

        final result = await _productRemoteDatasource.createProduct(
          productApiModel,
          productImages,
          imageSubFolder,
        );

        if (result == null) {
          return const Left(ApiFailure(message: "Failed to create product!"));
        }

        final normalizedImageUrls = HttpUrlUtil.normalizeHttpUrls(
          result.productImageUrls,
        );

        final newProduct = result.copyWith(
          productImageUrls: normalizedImageUrls,
        );

        return Right(newProduct.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message: e.response?.data["message"] ?? "Failed to create product!",
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final productHiveModel = ProductHiveModel.fromEntity(productEntity);

        final newProduct = await _productLocalDatasource.createProduct(
          productHiveModel,
        );
        if (newProduct == null) {
          return Left(LocalDatabaseFailure(message: "Product is not created!"));
        }

        return Right(newProduct.toEntity());
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failures, ProductEntity>> updateProduct(
    ProductEntity productEntity,
    List<File>? productImages,
    String? imageSubFolder,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final productApiModel = ProductApiModel.fromEntity(productEntity);

        final result = await _productRemoteDatasource.updateProduct(
          productApiModel,
          productImages,
          imageSubFolder,
        );

        if (result == null) {
          return const Left(ApiFailure(message: "Failed to update product!"));
        }

        final normalizedImageUrls = HttpUrlUtil.normalizeHttpUrls(
          result.productImageUrls,
        );

        final updatedProduct = result.copyWith(
          productImageUrls: normalizedImageUrls,
        );

        return Right(updatedProduct.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message: e.response?.data["message"] ?? "Failed to update product!",
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final productHiveModel = ProductHiveModel.fromEntity(productEntity);

        final existingProductById = await _productLocalDatasource
            .getProductById(productHiveModel.productId!);
        if (existingProductById == null) {
          return Left(
            LocalDatabaseFailure(
              message: "Product with the product id not found!",
            ),
          );
        }

        final updatedProduct = await _productLocalDatasource.updateProduct(
          productHiveModel,
        );
        if (updatedProduct == null) {
          return Left(LocalDatabaseFailure(message: "Product is not updated!"));
        }

        return Right(updatedProduct.toEntity());
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failures, bool>> deleteProduct(String productId) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _productRemoteDatasource.deleteProduct(productId);
        if (!result) {
          return const Left(ApiFailure(message: "Failed to delete product!"));
        }

        return Right(result);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message: e.response?.data["message"] ?? "Failed to delete product!",
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final result = await _productLocalDatasource.deleteProduct(productId);
        if (!result) {
          return const Left(
            LocalDatabaseFailure(message: "Product is not deleted!"),
          );
        }

        return Right(result);
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failures, ProductEntity>> getProductById(
    String productId,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _productRemoteDatasource.getProductById(productId);
        if (result == null) {
          return const Left(
            ApiFailure(message: "Failed! Product not found by id."),
          );
        }

        final normalizedImageUrls = HttpUrlUtil.normalizeHttpUrls(
          result.productImageUrls,
        );

        final product = result.copyWith(productImageUrls: normalizedImageUrls);

        return Right(product.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message:
                e.response?.data["message"] ?? "Failed to fetch product by id!",
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final result = await _productLocalDatasource.getProductById(productId);
        if (result == null) {
          return const Left(
            LocalDatabaseFailure(message: "Product not found by id!"),
          );
        }

        return Right(result.toEntity());
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failures, List<ProductEntity>>> getAllProducts() async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _productRemoteDatasource.getAllProducts();
        if (result.isEmpty) {
          return const Left(
            ApiFailure(message: "Failed to fetch all products!"),
          );
        }

        final normalizedProducts = result.map((product) {
          final normalizedImageUrls = HttpUrlUtil.normalizeHttpUrls(
            product.productImageUrls,
          );
          return product.copyWith(productImageUrls: normalizedImageUrls);
        }).toList();

        final products = ProductApiModel.toEntityList(normalizedProducts);

        return Right(products);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message:
                e.response?.data["message"] ?? "Failed to fetch all products!",
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final result = await _productLocalDatasource.getAllProducts();
        if (result.isEmpty) {
          return const Left(
            LocalDatabaseFailure(message: "Failed to fetch all products!"),
          );
        }

        final products = ProductHiveModel.toEntityList(result);

        return Right(products);
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failures, List<ProductEntity>>> getAllProductsByBuyerId(
    String buyerId,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _productRemoteDatasource.getAllProductsByBuyerId(
          buyerId,
        );

        if (result.isEmpty) {
          return const Left(
            ApiFailure(
              message: "Failed to fetch all products for buyer with buyer id!",
            ),
          );
        }

        final normalizedProducts = result.map((product) {
          final normalizedImageUrls = HttpUrlUtil.normalizeHttpUrls(
            product.productImageUrls,
          );
          return product.copyWith(productImageUrls: normalizedImageUrls);
        }).toList();

        final products = ProductApiModel.toEntityList(normalizedProducts);

        return Right(products);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message:
                e.response?.data["message"] ??
                "Failed to fetch all products for buyer with buyer id!",
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final result = await _productLocalDatasource.getAllProductsByBuyerId(
          buyerId,
        );
        if (result.isEmpty) {
          return const Left(
            LocalDatabaseFailure(
              message: "Failed to fetch all products for buyer with buyer id!",
            ),
          );
        }

        final products = ProductHiveModel.toEntityList(result);

        return Right(products);
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failures, List<ProductEntity>>> getAllProductsBySellerId(
    String sellerId,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _productRemoteDatasource.getAllProductsBySellerId(
          sellerId,
        );

        if (result.isEmpty) {
          return const Left(
            ApiFailure(
              message:
                  "Failed to fetch all products for seller with seller id!",
            ),
          );
        }

        final normalizedProducts = result.map((product) {
          final normalizedImageUrls = HttpUrlUtil.normalizeHttpUrls(
            product.productImageUrls,
          );
          return product.copyWith(productImageUrls: normalizedImageUrls);
        }).toList();

        final products = ProductApiModel.toEntityList(normalizedProducts);

        return Right(products);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message:
                e.response?.data["message"] ??
                "Failed to fetch all products for seller with seller id!",
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final result = await _productLocalDatasource.getAllProductsBySellerId(
          sellerId,
        );
        if (result.isEmpty) {
          return const Left(
            LocalDatabaseFailure(
              message:
                  "Failed to fetch all products for seller with seller id!",
            ),
          );
        }

        final products = ProductHiveModel.toEntityList(result);

        return Right(products);
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }
}
