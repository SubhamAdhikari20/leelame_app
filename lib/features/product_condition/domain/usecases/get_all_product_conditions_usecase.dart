// lib/features/product_condition/domain/usecases/get_all_product_conditions_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/core/usecases/app_usecase.dart';
import 'package:leelame/features/product_condition/data/repositories/product_condition_repository.dart';
import 'package:leelame/features/product_condition/domain/entities/product_condition_entity.dart';
import 'package:leelame/features/product_condition/domain/repositories/product_condition_repository.dart';

final getAllProductConditionsUsecaseProvider =
    Provider<GetAllProductConditionsUsecase>((ref) {
      final productConditionRepository = ref.read(
        productConditionRepositoryProvider,
      );
      return GetAllProductConditionsUsecase(
        productConditionRepository: productConditionRepository,
      );
    });

class GetAllProductConditionsUsecase
    implements UsecaseWithoutParams<List<ProductConditionEntity>> {
  final IProductConditionRepository _productConditionRepository;

  GetAllProductConditionsUsecase({
    required IProductConditionRepository productConditionRepository,
  }) : _productConditionRepository = productConditionRepository;

  @override
  Future<Either<Failures, List<ProductConditionEntity>>> call() async {
    return await _productConditionRepository.getAllProductConditions();
  }
}
