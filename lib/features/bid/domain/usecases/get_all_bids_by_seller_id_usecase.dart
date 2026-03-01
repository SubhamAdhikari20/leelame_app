// lib/features/bid/domain/usecases/get_all_bids_by_seller_id_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/core/usecases/app_usecase.dart';
import 'package:leelame/features/bid/data/repositories/bid_repository.dart';
import 'package:leelame/features/bid/domain/entities/bid_entity.dart';
import 'package:leelame/features/bid/domain/repositories/bid_repository.dart';

class GetAllBidsBySellerIdUsecaseParams extends Equatable {
  final String sellerId;

  const GetAllBidsBySellerIdUsecaseParams({required this.sellerId});

  @override
  List<Object?> get props => [sellerId];
}

final getAllBidsBySellerIdUsecaseProvider =
    Provider<GetAllBidsBySellerIdUsecase>((ref) {
      final bidRepository = ref.read(bidRepositoryProvider);
      return GetAllBidsBySellerIdUsecase(bidRepository: bidRepository);
    });

class GetAllBidsBySellerIdUsecase
    implements
        UsecaseWithParams<List<BidEntity>, GetAllBidsBySellerIdUsecaseParams> {
  final IBidRepository _bidRepository;

  GetAllBidsBySellerIdUsecase({required IBidRepository bidRepository})
    : _bidRepository = bidRepository;

  @override
  Future<Either<Failures, List<BidEntity>>> call(
    GetAllBidsBySellerIdUsecaseParams params,
  ) async {
    return await _bidRepository.getAllBidsBySellerId(params.sellerId);
  }
}
