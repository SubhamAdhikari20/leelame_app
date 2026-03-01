// lib/features/bid/domain/usecases/get_all_bids_by_buyer_id_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/core/usecases/app_usecase.dart';
import 'package:leelame/features/bid/data/repositories/bid_repository.dart';
import 'package:leelame/features/bid/domain/entities/bid_entity.dart';
import 'package:leelame/features/bid/domain/repositories/bid_repository.dart';

class GetAllBidsByBuyerIdUsecaseParams extends Equatable {
  final String buyerId;

  const GetAllBidsByBuyerIdUsecaseParams({required this.buyerId});

  @override
  List<Object?> get props => [buyerId];
}

final getAllBidsByBuyerIdUsecaseProvider = Provider<GetAllBidsByBuyerIdUsecase>(
  (ref) {
    final bidRepository = ref.read(bidRepositoryProvider);
    return GetAllBidsByBuyerIdUsecase(bidRepository: bidRepository);
  },
);

class GetAllBidsByBuyerIdUsecase
    implements
        UsecaseWithParams<List<BidEntity>, GetAllBidsByBuyerIdUsecaseParams> {
  final IBidRepository _bidRepository;

  GetAllBidsByBuyerIdUsecase({required IBidRepository bidRepository})
    : _bidRepository = bidRepository;

  @override
  Future<Either<Failures, List<BidEntity>>> call(
    GetAllBidsByBuyerIdUsecaseParams params,
  ) async {
    return await _bidRepository.getAllBidsByBuyerId(params.buyerId);
  }
}
