// lib/features/bid/domain/usecases/get_all_bids_by_product_id_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/core/usecases/app_usecase.dart';
import 'package:leelame/features/bid/data/repositories/bid_repository.dart';
import 'package:leelame/features/bid/domain/entities/bid_entity.dart';
import 'package:leelame/features/bid/domain/repositories/bid_repository.dart';

class GetAllBidsByProductIdUsecaseParams extends Equatable {
  final String productId;

  const GetAllBidsByProductIdUsecaseParams({required this.productId});

  @override
  List<Object?> get props => [productId];
}

final getAllBidsByProductIdUsecaseProvider = Provider<GetAllBidsByProductIdUsecase>(
  (ref) {
    final bidRepository = ref.read(bidRepositoryProvider);
    return GetAllBidsByProductIdUsecase(bidRepository: bidRepository);
  },
);

class GetAllBidsByProductIdUsecase
    implements
        UsecaseWithParams<List<BidEntity>, GetAllBidsByProductIdUsecaseParams> {
  final IBidRepository _bidRepository;

  GetAllBidsByProductIdUsecase({required IBidRepository bidRepository})
    : _bidRepository = bidRepository;

  @override
  Future<Either<Failures, List<BidEntity>>> call(
    GetAllBidsByProductIdUsecaseParams params,
  ) async {
    return await _bidRepository.getAllBidsByProductId(params.productId);
  }
}
