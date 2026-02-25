// lib/features/buyer/domain/usecases/get_all_buyers_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/core/usecases/app_usecase.dart';
import 'package:leelame/features/buyer/data/repositories/buyer_repository.dart';
import 'package:leelame/features/buyer/domain/entities/buyer_entity.dart';
import 'package:leelame/features/buyer/domain/repositories/buyer_repository.dart';

final getAllBuyersUsecaseProvider = Provider<GetAllBuyersUsecase>((ref) {
  final buyerRepository = ref.read(buyerRepositoryProvider);
  return GetAllBuyersUsecase(buyerRepository: buyerRepository);
});

class GetAllBuyersUsecase implements UsecaseWithoutParams<List<BuyerEntity>> {
  final IBuyerRepository _buyerRepository;

  GetAllBuyersUsecase({required IBuyerRepository buyerRepository})
    : _buyerRepository = buyerRepository;

  @override
  Future<Either<Failures, List<BuyerEntity>>> call() async {
    return await _buyerRepository.getAllBuyers();
  }
}
