// lib/features/bid/domain/usecases/create_bid_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/core/usecases/app_usecase.dart';
import 'package:leelame/features/bid/data/repositories/bid_repository.dart';
import 'package:leelame/features/bid/domain/entities/bid_entity.dart';
import 'package:leelame/features/bid/domain/repositories/bid_repository.dart';

class CreateBidUsecaseParams extends Equatable {
  final String productId;
  final String buyerId;
  final double bidAmount;

  const CreateBidUsecaseParams({
    required this.productId,
    required this.buyerId,
    required this.bidAmount,
  });

  @override
  List<Object?> get props => [productId, buyerId, bidAmount];
}

final createBidUsecaseProvider = Provider<CreateBidUsecase>((ref) {
  final bidRepository = ref.read(bidRepositoryProvider);
  return CreateBidUsecase(bidRepository: bidRepository);
});

class CreateBidUsecase
    implements UsecaseWithParams<BidEntity, CreateBidUsecaseParams> {
  final IBidRepository _bidRepository;
  CreateBidUsecase({required IBidRepository bidRepository})
    : _bidRepository = bidRepository;

  @override
  Future<Either<Failures, BidEntity>> call(
    CreateBidUsecaseParams params,
  ) async {
    final bidEntity = BidEntity(
      productId: params.productId,
      buyerId: params.buyerId,
      bidAmount: params.bidAmount,
    );
    return await _bidRepository.createBid(bidEntity);
  }
}
