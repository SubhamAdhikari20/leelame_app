// lib/features/seller/domain/usecases/get_seller_by_id_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/core/usecases/app_usecase.dart';
import 'package:leelame/features/seller/data/repositories/seller_repository.dart';
import 'package:leelame/features/seller/domain/entities/seller_entity.dart';
import 'package:leelame/features/seller/domain/repositories/seller_repository.dart';

class GetSellerByIdUsecaseParams extends Equatable {
  final String sellerId;

  const GetSellerByIdUsecaseParams({required this.sellerId});

  @override
  List<Object?> get props => [sellerId];
}

final getSellerByIdUsecaseProvider = Provider<GetSellerByIdUsecase>((ref) {
  final sellerRepository = ref.read(sellerRepositoryProvider);
  return GetSellerByIdUsecase(sellerRepository: sellerRepository);
});

class GetSellerByIdUsecase
    implements UsecaseWithParams<SellerEntity, GetSellerByIdUsecaseParams> {
  final ISellerRepository _sellerRepository;

  GetSellerByIdUsecase({required ISellerRepository sellerRepository})
    : _sellerRepository = sellerRepository;

  @override
  Future<Either<Failures, SellerEntity>> call(
    GetSellerByIdUsecaseParams params,
  ) async {
    return await _sellerRepository.getSellerById(params.sellerId);
  }
}
