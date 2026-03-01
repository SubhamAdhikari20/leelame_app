// lib/features/bid/data/repositories/bid_repository.dart
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/core/services/connectivity/network_info.dart';
import 'package:leelame/features/bid/data/datasources/bid_datasource.dart';
import 'package:leelame/features/bid/data/datasources/local/bid_local_datasource.dart';
import 'package:leelame/features/bid/data/datasources/remote/bid_remote_datasource.dart';
import 'package:leelame/features/bid/data/models/bid_api_model.dart';
import 'package:leelame/features/bid/data/models/bid_hive_model.dart';
import 'package:leelame/features/bid/domain/entities/bid_entity.dart';
import 'package:leelame/features/bid/domain/repositories/bid_repository.dart';

final bidRepositoryProvider = Provider<IBidRepository>((ref) {
  final bidLocalDatasource = ref.read(bidLocalDatasourceProvider);
  final bidRemoteDatasource = ref.read(bidRemoteDatasourceProvider);
  final networkInfo = ref.read(networkInfoProvider);

  return BidRepository(
    bidLocalDatasource: bidLocalDatasource,
    bidRemoteDatasource: bidRemoteDatasource,
    networkInfo: networkInfo,
  );
});

class BidRepository implements IBidRepository {
  final IBidLocalDatasource _bidLocalDatasource;
  final IBidRemoteDatasource _bidRemoteDatasource;
  final INetworkInfo _networkInfo;

  BidRepository({
    required IBidLocalDatasource bidLocalDatasource,
    required IBidRemoteDatasource bidRemoteDatasource,
    required INetworkInfo networkInfo,
  }) : _bidLocalDatasource = bidLocalDatasource,
       _bidRemoteDatasource = bidRemoteDatasource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failures, BidEntity>> createBid(BidEntity bidEntity) async {
    if (await _networkInfo.isConnected) {
      try {
        final bidApiModel = BidApiModel.fromEntity(bidEntity);

        final result = await _bidRemoteDatasource.createBid(bidApiModel);
        if (result == null) {
          return const Left(ApiFailure(message: "Failed to create bid!"));
        }

        return Right(result.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message: e.response?.data["message"] ?? "Failed to create bid!",
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final bidHiveModel = BidHiveModel.fromEntity(bidEntity);
        final exisitingProductById = await _bidLocalDatasource.getProductById(
          bidEntity.productId!,
        );
        if (exisitingProductById == null) {
          return Left(
            LocalDatabaseFailure(message: "Product with this id not found!"),
          );
        }

        final minRequiredBidAmount =
            exisitingProductById.currentBidPrice +
            exisitingProductById.bidIntervalPrice;
        if (bidEntity.bidAmount < minRequiredBidAmount) {
          return Left(
            LocalDatabaseFailure(
              message:
                  "Your bid must be greater than or equal to the sum of current bid and bid interval price (Rs.${minRequiredBidAmount.toStringAsFixed(2)})",
            ),
          );
        }

        // final endDate = new DateTime(exisitingProductById.endDate).getTime();
        // final now = new DateTime().getTime();
        // final difference = endDate - now;
        final endDate = DateTime.parse(exisitingProductById.endDate.toString());
        final now = DateTime.now();
        final difference = endDate.difference(now).inMilliseconds;

        if (difference <= 0) {
          return Left(
            LocalDatabaseFailure(
              message: "Auction has already ended for this product!",
            ),
          );
        }

        final newBid = await _bidLocalDatasource.createBid(bidHiveModel);
        if (newBid == null) {
          return Left(LocalDatabaseFailure(message: "Bid is not created!"));
        }

        return Right(newBid.toEntity());
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failures, BidEntity>> updateBid(BidEntity bidEntity) async {
    if (await _networkInfo.isConnected) {
      try {
        final bidApiModel = BidApiModel.fromEntity(bidEntity);

        final result = await _bidRemoteDatasource.updateBid(bidApiModel);
        if (result == null) {
          return const Left(ApiFailure(message: "Failed to update bid!"));
        }

        return Right(result.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message: e.response?.data["message"] ?? "Failed to update bid!",
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final bidHiveModel = BidHiveModel.fromEntity(bidEntity);

        final existingBidById = await _bidLocalDatasource.getBidById(
          bidHiveModel.bidId!,
        );
        if (existingBidById == null) {
          return Left(
            LocalDatabaseFailure(message: "Bid with the bid id not found!"),
          );
        }

        final exisitingProductById = await _bidLocalDatasource.getProductById(
          bidEntity.productId!,
        );
        if (exisitingProductById == null) {
          return Left(
            LocalDatabaseFailure(message: "Product with this id not found!"),
          );
        }

        final minRequiredBidAmount =
            exisitingProductById.currentBidPrice +
            exisitingProductById.bidIntervalPrice;
        if (bidEntity.bidAmount < minRequiredBidAmount) {
          return Left(
            LocalDatabaseFailure(
              message:
                  "Your bid must be greater than or equal to the sum of current bid and bid interval price (Rs.${minRequiredBidAmount.toStringAsFixed(2)})",
            ),
          );
        }

        final endDate = DateTime.parse(exisitingProductById.endDate.toString());
        final now = DateTime.now();
        final difference = endDate.difference(now).inMilliseconds;

        if (difference <= 0) {
          return Left(
            LocalDatabaseFailure(
              message: "Auction has already ended for this product!",
            ),
          );
        }

        final updatedBid = await _bidLocalDatasource.updateBid(bidHiveModel);
        if (updatedBid == null) {
          return Left(LocalDatabaseFailure(message: "Bid is not updated!"));
        }

        return Right(updatedBid.toEntity());
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failures, bool>> deleteBid(String bidId) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _bidRemoteDatasource.deleteBid(bidId);
        if (!result) {
          return const Left(ApiFailure(message: "Failed to delete bid!"));
        }

        return Right(result);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message: e.response?.data["message"] ?? "Failed to delete bid!",
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final result = await _bidLocalDatasource.deleteBid(bidId);
        if (!result) {
          return const Left(
            LocalDatabaseFailure(message: "Bid is not deleted!"),
          );
        }

        return Right(result);
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failures, BidEntity>> getBidById(String bidId) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _bidRemoteDatasource.getBidById(bidId);
        if (result == null) {
          return const Left(
            ApiFailure(message: "Failed! Bid not found by id."),
          );
        }

        return Right(result.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message:
                e.response?.data["message"] ?? "Failed to get the bid by id!",
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final result = await _bidLocalDatasource.getBidById(bidId);
        if (result == null) {
          return const Left(
            LocalDatabaseFailure(message: "Bid with this id not found!"),
          );
        }

        return Right(result.toEntity());
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failures, List<BidEntity>>> getAllBids() async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _bidRemoteDatasource.getAllBids();
        if (result.isEmpty) {
          return Left(ApiFailure(message: "Failed to fetch all bids!"));
        }

        final bids = BidApiModel.toEntityList(result);

        return Right(bids);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message: e.response?.data["message"] ?? "Failed to fetch all bids!",
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final result = await _bidLocalDatasource.getAllBids();
        if (result.isEmpty) {
          return Left(
            LocalDatabaseFailure(message: "Failed to fetch all bids!"),
          );
        }

        final bids = BidHiveModel.toEntityList(result);
        return Right(bids);
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failures, List<BidEntity>>> getAllBidsByBuyerId(
    String buyerId,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _bidRemoteDatasource.getAllBidsByBuyerId(buyerId);
        if (result.isEmpty) {
          return Left(
            ApiFailure(
              message: "Failed to fetch all bids with  this buyer id!!",
            ),
          );
        }

        final bids = BidApiModel.toEntityList(result);

        return Right(bids);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message:
                e.response?.data["message"] ??
                "Failed to fetch all bids with this buyer id!",
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final result = await _bidLocalDatasource.getAllBidsByBuyerId(buyerId);
        if (result.isEmpty) {
          return Left(
            LocalDatabaseFailure(
              message: "Failed to fetch all bids with this buyer id!",
            ),
          );
        }

        final bids = BidHiveModel.toEntityList(result);
        return Right(bids);
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failures, List<BidEntity>>> getAllBidsByProductId(
    String productId,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _bidRemoteDatasource.getAllBidsByProductId(
          productId,
        );
        if (result.isEmpty) {
          return Left(
            ApiFailure(
              message: "Failed to fetch all bids with  this product id!!",
            ),
          );
        }

        final bids = BidApiModel.toEntityList(result);

        return Right(bids);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message:
                e.response?.data["message"] ??
                "Failed to fetch all bids with this product id!",
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final result = await _bidLocalDatasource.getAllBidsByProductId(
          productId,
        );
        if (result.isEmpty) {
          return Left(
            LocalDatabaseFailure(
              message: "Failed to fetch all bids with this product id!",
            ),
          );
        }

        final bids = BidHiveModel.toEntityList(result);
        return Right(bids);
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failures, List<BidEntity>>> getAllBidsBySellerId(
    String sellerId,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _bidRemoteDatasource.getAllBidsBySellerId(
          sellerId,
        );
        if (result.isEmpty) {
          return Left(
            ApiFailure(
              message: "Failed to fetch all bids with  this seller id!!",
            ),
          );
        }

        final bids = BidApiModel.toEntityList(result);

        return Right(bids);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message:
                e.response?.data["message"] ??
                "Failed to fetch all bids with this seller id!",
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final result = await _bidLocalDatasource.getAllBidsBySellerId(sellerId);
        if (result.isEmpty) {
          return Left(
            LocalDatabaseFailure(
              message: "Failed to fetch all bids with this seller id!",
            ),
          );
        }

        final bids = BidHiveModel.toEntityList(result);
        return Right(bids);
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }
}
