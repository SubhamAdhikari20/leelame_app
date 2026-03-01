// lib/features/bid/domain/usecases/delete_bid_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/core/usecases/app_usecase.dart';
import 'package:leelame/features/bid/data/repositories/bid_repository.dart';
import 'package:leelame/features/bid/domain/repositories/bid_repository.dart';

class DeleteBidUsecaseParams extends Equatable {
  final String bidId;

  const DeleteBidUsecaseParams({required this.bidId});

  @override
  List<Object?> get props => [bidId];
}

final deleteBidUsecaseProvider = Provider<DeleteBidUsecase>((ref) {
  final bidRepository = ref.read(bidRepositoryProvider);
  return DeleteBidUsecase(bidRepository: bidRepository);
});

class DeleteBidUsecase
    implements UsecaseWithParams<bool, DeleteBidUsecaseParams> {
  final IBidRepository _bidRepository;
  DeleteBidUsecase({required IBidRepository bidRepository})
    : _bidRepository = bidRepository;

  @override
  Future<Either<Failures, bool>> call(DeleteBidUsecaseParams params) async {
    return await _bidRepository.deleteBid(params.bidId);
  }
}
