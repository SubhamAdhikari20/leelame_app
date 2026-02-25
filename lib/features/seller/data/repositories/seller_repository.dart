// lib/features/seller/data/repositories/seller_repository.dart
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/core/services/connectivity/network_info.dart';
import 'package:leelame/core/utils/http_url_util.dart';
import 'package:leelame/features/seller/data/datasources/seller_datasource.dart';
import 'package:leelame/features/seller/data/datasources/local/seller_local_datasource.dart';
import 'package:leelame/features/seller/data/datasources/remote/seller_remote_datasource.dart';
import 'package:leelame/features/seller/data/models/seller_api_model.dart';
import 'package:leelame/features/seller/data/models/seller_hive_model.dart';
import 'package:leelame/features/seller/domain/entities/seller_entity.dart';
import 'package:leelame/features/seller/domain/repositories/seller_repository.dart';

final sellerRepositoryProvider = Provider<ISellerRepository>((ref) {
  final sellerLocalDatasource = ref.read(sellerLocalDatasourceProvider);
  final sellerRemoteDatasource = ref.read(sellerRemoteDatasourceProvider);
  final networkInfo = ref.read(networkInfoProvider);

  return SellerRepository(
    sellerLocalDatasource: sellerLocalDatasource,
    sellerRemoteDatasource: sellerRemoteDatasource,
    networkInfo: networkInfo,
  );
});

class SellerRepository implements ISellerRepository {
  final ISellerLocalDatasource _sellerLocalDatasource;
  final ISellerRemoteDatasource _sellerRemoteDatasource;
  final INetworkInfo _networkInfo;

  SellerRepository({
    required ISellerLocalDatasource sellerLocalDatasource,
    required ISellerRemoteDatasource sellerRemoteDatasource,
    required INetworkInfo networkInfo,
  }) : _sellerLocalDatasource = sellerLocalDatasource,
       _sellerRemoteDatasource = sellerRemoteDatasource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failures, SellerEntity>> getCurrentSeller(
    String sellerId,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final seller = await _sellerRemoteDatasource.getCurrentSeller(sellerId);
        if (seller == null) {
          return const Left(
            ApiFailure(message: "Failed to get current seller!"),
          );
        }

        return Right(seller.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message:
                e.response?.data["message"] ?? "Failed to get current seller!",
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final seller = await _sellerLocalDatasource.getSellerById(sellerId);
        if (seller == null) {
          return const Left(
            LocalDatabaseFailure(message: "Failed to get current seller!"),
          );
        }

        final user = await _sellerLocalDatasource.getBaseUserById(
          seller.baseUserId!,
        );
        if (user == null) {
          return const Left(
            LocalDatabaseFailure(message: "Failed to get current base user!"),
          );
        }

        return Right(seller.toEntity(userEntity: user.toEntity()));
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failures, SellerEntity>> updateSeller(
    SellerEntity sellerEntity,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final sellerApiModel = SellerApiModel.fromEntity(sellerEntity);

        final result = await _sellerRemoteDatasource.updateSeller(
          sellerApiModel,
        );
        if (result == null) {
          return const Left(
            ApiFailure(message: "Failed! seller is not updated."),
          );
        }

        return Right(result.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message: e.response?.data["message"] ?? "Failed to update seller!",
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final sellerModel = SellerHiveModel.fromEntity(sellerEntity);
        final result = await _sellerLocalDatasource.updateSeller(sellerModel);
        if (result == null) {
          return const Left(
            LocalDatabaseFailure(message: "Failed to update seller"),
          );
        }
        return Right(result.toEntity());
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failures, String>> uploadSellerProfilePicture(
    String sellerId,
    File profilePicture,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final imageUrl = await _sellerRemoteDatasource
            .uploadSellerProfilePicture(sellerId, profilePicture);
        if (imageUrl == null) {
          return const Left(
            ApiFailure(
              message: "Null image url! The image url is not fetched.",
            ),
          );
        }

        return Right(imageUrl);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message:
                e.response?.data["message"] ??
                "Failed to upload profile picture!",
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return const Left(NetworkFailure(message: "No internet connection"));
    }
  }

  @override
  Future<Either<Failures, List<SellerEntity>>> getAllSellers() async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _sellerRemoteDatasource.getAllSellers();
        if (result.isEmpty) {
          return const Left(ApiFailure(message: "Failed to fetch sellers!"));
        }

        final normalizedSellers = result.map((seller) {
          final normalizedProfilePictureUrl = HttpUrlUtil.normalizeHttpUrl(
            seller.profilePictureUrl,
          );
          return seller.copyWith(
            profilePictureUrl: normalizedProfilePictureUrl,
          );
        }).toList();

        final sellers = SellerApiModel.toEntityList(normalizedSellers);

        return Right(sellers);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message: e.response?.data["message"] ?? "Failed to fetch sellers!",
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final result = await _sellerLocalDatasource.getAllSellers();
        if (result.isEmpty) {
          return const Left(
            LocalDatabaseFailure(message: "Failed to fetch sellers!"),
          );
        }

        final sellers = SellerHiveModel.toEntityList(result);

        return Right(sellers);
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }
}
