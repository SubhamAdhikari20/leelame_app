// lib/features/bid/domain/usecases/get_bid_by_id_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/core/usecases/app_usecase.dart';
import 'package:leelame/features/bid/data/repositories/bid_repository.dart';
import 'package:leelame/features/bid/domain/entities/bid_entity.dart';
import 'package:leelame/features/bid/domain/repositories/bid_repository.dart';

class GetBidByIdUsecaseParams extends Equatable {
  final String bidId;

  const GetBidByIdUsecaseParams({required this.bidId});

  @override
  List<Object?> get props => [bidId];
}

final getBidByIdUsecaseProvider = Provider<GetBidByIdUsecase>((ref) {
  final bidRepository = ref.read(bidRepositoryProvider);
  return GetBidByIdUsecase(bidRepository: bidRepository);
});

class GetBidByIdUsecase
    implements UsecaseWithParams<BidEntity, GetBidByIdUsecaseParams> {
  final IBidRepository _bidRepository;

  GetBidByIdUsecase({required IBidRepository bidRepository})
    : _bidRepository = bidRepository;

  @override
  Future<Either<Failures, BidEntity>> call(
    GetBidByIdUsecaseParams params,
  ) async {
    return await _bidRepository.getBidById(params.bidId);
  }
}
