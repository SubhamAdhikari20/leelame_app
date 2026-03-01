// lib/features/bid/domain/repositories/bid_repository.dart
import 'package:dartz/dartz.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/features/bid/domain/entities/bid_entity.dart';

abstract interface class IBidRepository {
  Future<Either<Failures, BidEntity>> createBid(BidEntity bidEntity);
  Future<Either<Failures, BidEntity>> updateBid(BidEntity bidEntity);
  Future<Either<Failures, BidEntity>> getBidById(String bidId);
  Future<Either<Failures, bool>> deleteBid(String bidId);
  Future<Either<Failures, List<BidEntity>>> getAllBids();
  Future<Either<Failures, List<BidEntity>>> getAllBidsByProductId(
    String productId,
  );
  Future<Either<Failures, List<BidEntity>>> getAllBidsByBuyerId(String buyerId);
  Future<Either<Failures, List<BidEntity>>> getAllBidsBySellerId(
    String sellerId,
  );
}
