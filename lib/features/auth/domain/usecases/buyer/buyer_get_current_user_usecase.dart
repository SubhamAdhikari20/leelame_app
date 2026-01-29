import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/core/usecases/app_usecase.dart';
import 'package:leelame/features/auth/data/repositories/buyer_auth_repository.dart';
import 'package:leelame/features/auth/domain/repositories/buyer_auth_repository.dart';
import 'package:leelame/features/buyer/domain/entities/buyer_entity.dart';

class BuyerGetCurrentUserUsecaseParams extends Equatable {
  final String buyerId;

  const BuyerGetCurrentUserUsecaseParams({required this.buyerId});

  @override
  List<Object?> get props => [buyerId];
}

final buyerGetCurrentUserUsecaseProvider = Provider<BuyerGetCurrentUserUsecase>(
  (ref) {
    final buyerAuthRepository = ref.read(buyerAuthRepositoryProvider);
    return BuyerGetCurrentUserUsecase(buyerAuthRepository: buyerAuthRepository);
  },
);

class BuyerGetCurrentUserUsecase
    implements
        UsecaseWithParams<BuyerEntity, BuyerGetCurrentUserUsecaseParams> {
  final IBuyerAuthRepository _buyerAuthRepository;

  BuyerGetCurrentUserUsecase({
    required IBuyerAuthRepository buyerAuthRepository,
  }) : _buyerAuthRepository = buyerAuthRepository;

  @override
  Future<Either<Failures, BuyerEntity>> call(
    BuyerGetCurrentUserUsecaseParams params,
  ) async {
    return await _buyerAuthRepository.getCurrentBuyer(params.buyerId);
  }
}
