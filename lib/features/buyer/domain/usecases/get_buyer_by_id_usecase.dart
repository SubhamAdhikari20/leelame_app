// lib/features/buyer/domain/usecases/get_buyer_by_id_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/core/usecases/app_usecase.dart';
import 'package:leelame/features/buyer/data/repositories/buyer_repository.dart';
import 'package:leelame/features/buyer/domain/entities/buyer_entity.dart';
import 'package:leelame/features/buyer/domain/repositories/buyer_repository.dart';

class GetBuyerByIdUsecaseParams extends Equatable {
  final String buyerId;

  const GetBuyerByIdUsecaseParams({required this.buyerId});

  @override
  List<Object?> get props => [buyerId];
}

final getBuyerByIdUsecaseProvider = Provider<GetBuyerByIdUsecase>((ref) {
  final buyerRepository = ref.read(buyerRepositoryProvider);
  return GetBuyerByIdUsecase(buyerRepository: buyerRepository);
});

class GetBuyerByIdUsecase
    implements UsecaseWithParams<BuyerEntity, GetBuyerByIdUsecaseParams> {
  final IBuyerRepository _buyerRepository;

  GetBuyerByIdUsecase({required IBuyerRepository buyerRepository})
    : _buyerRepository = buyerRepository;

  @override
  Future<Either<Failures, BuyerEntity>> call(
    GetBuyerByIdUsecaseParams params,
  ) async {
    return await _buyerRepository.getBuyerById(params.buyerId);
  }
}
