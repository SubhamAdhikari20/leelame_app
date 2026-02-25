// lib/features/seller/domain/usecases/seller_get_current_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/core/usecases/app_usecase.dart';
import 'package:leelame/features/seller/data/repositories/seller_repository.dart';
import 'package:leelame/features/seller/domain/entities/seller_entity.dart';
import 'package:leelame/features/seller/domain/repositories/seller_repository.dart';

class GetCurrentSellerUsecaseParams extends Equatable {
  final String sellerId;

  const GetCurrentSellerUsecaseParams({required this.sellerId});

  @override
  List<Object?> get props => [sellerId];
}

final getCurrentSellerUsecaseProvider = Provider<GetCurrentSellerUsecase>((
  ref,
) {
  final sellerRepository = ref.read(sellerRepositoryProvider);
  return GetCurrentSellerUsecase(sellerRepository: sellerRepository);
});

class GetCurrentSellerUsecase
    implements UsecaseWithParams<SellerEntity, GetCurrentSellerUsecaseParams> {
  final ISellerRepository _sellerRepository;

  GetCurrentSellerUsecase({required ISellerRepository sellerRepository})
    : _sellerRepository = sellerRepository;

  @override
  Future<Either<Failures, SellerEntity>> call(
    GetCurrentSellerUsecaseParams params,
  ) async {
    return await _sellerRepository.getCurrentSeller(params.sellerId);
  }
}
