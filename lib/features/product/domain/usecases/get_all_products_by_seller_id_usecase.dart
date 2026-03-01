// lib/features/product/domain/usecases/get_all_products_by_seller_id_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/core/usecases/app_usecase.dart';
import 'package:leelame/features/product/data/repositories/product_repository.dart';
import 'package:leelame/features/product/domain/entities/product_entity.dart';
import 'package:leelame/features/product/domain/repositories/product_repository.dart';

class GetAllProductsBySellerIdUsecaseParams extends Equatable {
  final String sellerId;

  const GetAllProductsBySellerIdUsecaseParams({required this.sellerId});

  @override
  List<Object?> get props => [sellerId];
}

final getAllProductsBySellerIdUsecaseProvider =
    Provider<GetAllProductsBySellerIdUsecase>((ref) {
      final productRepository = ref.read(productRepositoryProvider);
      return GetAllProductsBySellerIdUsecase(
        productRepository: productRepository,
      );
    });

class GetAllProductsBySellerIdUsecase
    implements
        UsecaseWithParams<
          List<ProductEntity>,
          GetAllProductsBySellerIdUsecaseParams
        > {
  final IProductRepository _productRepository;

  GetAllProductsBySellerIdUsecase({
    required IProductRepository productRepository,
  }) : _productRepository = productRepository;

  @override
  Future<Either<Failures, List<ProductEntity>>> call(
    GetAllProductsBySellerIdUsecaseParams params,
  ) async {
    return await _productRepository.getAllProductsBySellerId(params.sellerId);
  }
}
