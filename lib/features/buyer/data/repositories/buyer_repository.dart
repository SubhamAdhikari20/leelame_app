// lib/features/buyer/data/repositories/buyer_repository.dart
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/core/services/connectivity/network_info.dart';
import 'package:leelame/features/buyer/data/datasources/buyer_datasource.dart';
import 'package:leelame/features/buyer/data/datasources/local/buyer_local_datasource.dart';
import 'package:leelame/features/buyer/data/datasources/remote/buyer_remote_datasource.dart';
import 'package:leelame/features/buyer/data/models/buyer_api_model.dart';
import 'package:leelame/features/buyer/data/models/buyer_hive_model.dart';
import 'package:leelame/features/buyer/domain/entities/buyer_entity.dart';
import 'package:leelame/features/buyer/domain/repositories/buyer_repository.dart';

final buyerRepositoryProvider = Provider<IBuyerRepository>((ref) {
  final buyerLocalDatasource = ref.read(buyerLocalDatasourceProvider);
  final buyerRemoteDatasource = ref.read(buyerRemoteDatasourceProvider);
  final networkInfo = ref.read(networkInfoProvider);

  return BuyerRepository(
    buyerLocalDatasource: buyerLocalDatasource,
    buyerRemoteDatasource: buyerRemoteDatasource,
    networkInfo: networkInfo,
  );
});

class BuyerRepository implements IBuyerRepository {
  final IBuyerLocalDatasource _buyerLocalDatasource;
  final IBuyerRemoteDatasource _buyerRemoteDatasource;
  final INetworkInfo _networkInfo;

  BuyerRepository({
    required IBuyerLocalDatasource buyerLocalDatasource,
    required IBuyerRemoteDatasource buyerRemoteDatasource,
    required INetworkInfo networkInfo,
  }) : _buyerLocalDatasource = buyerLocalDatasource,
       _buyerRemoteDatasource = buyerRemoteDatasource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failures, BuyerEntity>> getCurrentBuyer(String buyerId) async {
    if (await _networkInfo.isConnected) {
      try {
        final buyer = await _buyerRemoteDatasource.getCurrentBuyer(buyerId);
        if (buyer == null) {
          return const Left(
            ApiFailure(message: "Failed to get current buyer!"),
          );
        }

        return Right(buyer.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message:
                e.response?.data["message"] ?? "Failed to get current buyer!",
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final buyer = await _buyerLocalDatasource.getBuyerById(buyerId);
        if (buyer == null) {
          return const Left(
            LocalDatabaseFailure(message: "Failed to get current buyer!"),
          );
        }

        final user = await _buyerLocalDatasource.getBaseUserById(
          buyer.baseUserId!,
        );
        if (user == null) {
          return const Left(
            LocalDatabaseFailure(message: "Failed to get current base user!"),
          );
        }

        return Right(buyer.toEntity(userEntity: user.toEntity()));
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failures, BuyerEntity>> updateBuyer(
    BuyerEntity buyerEntity,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final buyerApiModel = BuyerApiModel.fromEntity(buyerEntity);

        final result = await _buyerRemoteDatasource.updateBuyer(buyerApiModel);
        if (result == null) {
          return const Left(
            ApiFailure(message: "Failed! buyer is not updated."),
          );
        }

        return Right(result.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message: e.response?.data["message"] ?? "Failed to update buyer!",
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final buyerModel = BuyerHiveModel.fromEntity(buyerEntity);
        final result = await _buyerLocalDatasource.updateBuyer(buyerModel);
        if (result == null) {
          return const Left(
            LocalDatabaseFailure(message: "Failed to update buyer"),
          );
        }
        return Right(result.toEntity());
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failures, String>> uploadBuyerProfilePicture(
    String buyerId,
    File profilePicture,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final imageUrl = await _buyerRemoteDatasource.uploadBuyerProfilePicture(
          buyerId,
          profilePicture,
        );
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
}
