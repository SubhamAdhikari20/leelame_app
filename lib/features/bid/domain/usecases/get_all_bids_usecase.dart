// lib/features/bid/domain/usecases/get_all_bids_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/core/usecases/app_usecase.dart';
import 'package:leelame/features/bid/data/repositories/bid_repository.dart';
import 'package:leelame/features/bid/domain/entities/bid_entity.dart';
import 'package:leelame/features/bid/domain/repositories/bid_repository.dart';

final getAllBidsUsecaseProvider = Provider<GetAllBidsUsecase>((ref) {
  final bidRepository = ref.read(bidRepositoryProvider);
  return GetAllBidsUsecase(bidRepository: bidRepository);
});

class GetAllBidsUsecase implements UsecaseWithoutParams<List<BidEntity>> {
  final IBidRepository _bidRepository;

  GetAllBidsUsecase({required IBidRepository bidRepository})
    : _bidRepository = bidRepository;

  @override
  Future<Either<Failures, List<BidEntity>>> call() async {
    return await _bidRepository.getAllBids();
  }
}
