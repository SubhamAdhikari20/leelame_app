// lib/features/buyer/domain/usecases/buyer_get_current_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/core/usecases/app_usecase.dart';
import 'package:leelame/features/buyer/data/repositories/buyer_repository.dart';
import 'package:leelame/features/buyer/domain/entities/buyer_entity.dart';
import 'package:leelame/features/buyer/domain/repositories/buyer_repository.dart';

class BuyerGetCurrentUserUsecaseParams extends Equatable {
  final String buyerId;

  const BuyerGetCurrentUserUsecaseParams({required this.buyerId});

  @override
  List<Object?> get props => [buyerId];
}

final buyerGetCurrentUserUsecaseProvider = Provider<BuyerGetCurrentUserUsecase>(
  (ref) {
    final buyerRepository = ref.read(buyerRepositoryProvider);
    return BuyerGetCurrentUserUsecase(buyerRepository: buyerRepository);
  },
);

class BuyerGetCurrentUserUsecase
    implements
        UsecaseWithParams<BuyerEntity, BuyerGetCurrentUserUsecaseParams> {
  final IBuyerRepository _buyerRepository;

  BuyerGetCurrentUserUsecase({required IBuyerRepository buyerRepository})
    : _buyerRepository = buyerRepository;

  @override
  Future<Either<Failures, BuyerEntity>> call(
    BuyerGetCurrentUserUsecaseParams params,
  ) async {
    return await _buyerRepository.getCurrentBuyer(params.buyerId);
  }
}
