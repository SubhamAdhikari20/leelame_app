// lib/features/bid/domain/usecases/update_bid_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/core/usecases/app_usecase.dart';
import 'package:leelame/features/bid/data/repositories/bid_repository.dart';
import 'package:leelame/features/bid/domain/entities/bid_entity.dart';
import 'package:leelame/features/bid/domain/repositories/bid_repository.dart';

class UpdateBidUsecaseParams extends Equatable {
  final String bidId;
  final String productId;
  final String buyerId;
  final double bidAmount;

  const UpdateBidUsecaseParams({
    required this.bidId,
    required this.productId,
    required this.buyerId,
    required this.bidAmount,
  });

  @override
  List<Object?> get props => [bidId, productId, buyerId, bidAmount];
}

final updateBidUsecaseProvider = Provider<UpdateBidUsecase>((ref) {
  final bidRepository = ref.read(bidRepositoryProvider);
  return UpdateBidUsecase(bidRepository: bidRepository);
});

class UpdateBidUsecase
    implements UsecaseWithParams<BidEntity, UpdateBidUsecaseParams> {
  final IBidRepository _bidRepository;
  UpdateBidUsecase({required IBidRepository bidRepository})
    : _bidRepository = bidRepository;

  @override
  Future<Either<Failures, BidEntity>> call(
    UpdateBidUsecaseParams params,
  ) async {
    final bidEntity = BidEntity(
      bidId: params.bidId,
      productId: params.productId,
      buyerId: params.buyerId,
      bidAmount: params.bidAmount,
    );
    return await _bidRepository.updateBid(bidEntity);
  }
}
