// lib/features/product/domain/usecases/get_all_products_by_buyer_id_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/core/usecases/app_usecase.dart';
import 'package:leelame/features/product/data/repositories/product_repository.dart';
import 'package:leelame/features/product/domain/entities/product_entity.dart';
import 'package:leelame/features/product/domain/repositories/product_repository.dart';

class GetAllProductsByBuyerIdUsecaseParams extends Equatable {
  final String buyerId;

  const GetAllProductsByBuyerIdUsecaseParams({required this.buyerId});

  @override
  List<Object?> get props => [buyerId];
}

final getAllProductsByBuyerIdUsecaseProvider =
    Provider<GetAllProductsByBuyerIdUsecase>((ref) {
      final productRepository = ref.read(productRepositoryProvider);
      return GetAllProductsByBuyerIdUsecase(
        productRepository: productRepository,
      );
    });

class GetAllProductsByBuyerIdUsecase
    implements
        UsecaseWithParams<
          List<ProductEntity>,
          GetAllProductsByBuyerIdUsecaseParams
        > {
  final IProductRepository _productRepository;

  GetAllProductsByBuyerIdUsecase({
    required IProductRepository productRepository,
  }) : _productRepository = productRepository;

  @override
  Future<Either<Failures, List<ProductEntity>>> call(
    GetAllProductsByBuyerIdUsecaseParams params,
  ) async {
    return await _productRepository.getAllProductsByBuyerId(params.buyerId);
  }
}
