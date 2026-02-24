// lib/features/product_condition/domain/usecases/get_product_condition_by_id_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/core/usecases/app_usecase.dart';
import 'package:leelame/features/product_condition/data/repositories/product_condition_repository.dart';
import 'package:leelame/features/product_condition/domain/entities/product_condition_entity.dart';
import 'package:leelame/features/product_condition/domain/repositories/product_condition_repository.dart';

class GetProductConditionByIdUsecaseParams extends Equatable {
  final String productConditionId;

  const GetProductConditionByIdUsecaseParams({
    required this.productConditionId,
  });

  @override
  List<Object?> get props => [productConditionId];
}

final getProductConditionByIdUsecaseProvider =
    Provider<GetProductConditionByIdUsecase>((ref) {
      final productConditionRepository = ref.read(
        productConditionRepositoryProvider,
      );
      return GetProductConditionByIdUsecase(
        productConditionRepository: productConditionRepository,
      );
    });

class GetProductConditionByIdUsecase
    implements
        UsecaseWithParams<
          ProductConditionEntity,
          GetProductConditionByIdUsecaseParams
        > {
  final IProductConditionRepository _productConditionRepository;

  GetProductConditionByIdUsecase({
    required IProductConditionRepository productConditionRepository,
  }) : _productConditionRepository = productConditionRepository;

  @override
  Future<Either<Failures, ProductConditionEntity>> call(
    GetProductConditionByIdUsecaseParams params,
  ) async {
    return await _productConditionRepository.getProductConditionById(
      params.productConditionId,
    );
  }
}
