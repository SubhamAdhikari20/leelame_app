// lib/features/seller/domain/usecases/get_all_sellers_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/core/usecases/app_usecase.dart';
import 'package:leelame/features/seller/data/repositories/seller_repository.dart';
import 'package:leelame/features/seller/domain/entities/seller_entity.dart';
import 'package:leelame/features/seller/domain/repositories/seller_repository.dart';

final getAllSellersUsecaseProvider = Provider<GetAllSellersUsecase>((ref) {
  final sellerRepository = ref.read(sellerRepositoryProvider);
  return GetAllSellersUsecase(sellerRepository: sellerRepository);
});

class GetAllSellersUsecase implements UsecaseWithoutParams<List<SellerEntity>> {
  final ISellerRepository _sellerRepository;

  GetAllSellersUsecase({required ISellerRepository sellerRepository})
    : _sellerRepository = sellerRepository;

  @override
  Future<Either<Failures, List<SellerEntity>>> call() async {
    return await _sellerRepository.getAllSellers();
  }
}
