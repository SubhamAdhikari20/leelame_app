// lib/features/product/domain/usecases/get_product_by_id_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/core/usecases/app_usecase.dart';
import 'package:leelame/features/product/data/repositories/product_repository.dart';
import 'package:leelame/features/product/domain/entities/product_entity.dart';
import 'package:leelame/features/product/domain/repositories/product_repository.dart';

class GetProductByIdUsecaseParams extends Equatable {
  final String productId;

  const GetProductByIdUsecaseParams({required this.productId});

  @override
  List<Object?> get props => [productId];
}

final getProductByIdUsecaseProvider = Provider<GetProductByIdUsecase>((ref) {
  final productRepository = ref.read(productRepositoryProvider);
  return GetProductByIdUsecase(productRepository: productRepository);
});

class GetProductByIdUsecase
    implements UsecaseWithParams<ProductEntity, GetProductByIdUsecaseParams> {
  final IProductRepository _productRepository;

  GetProductByIdUsecase({required IProductRepository productRepository})
    : _productRepository = productRepository;

  @override
  Future<Either<Failures, ProductEntity>> call(
    GetProductByIdUsecaseParams params,
  ) async {
    return await _productRepository.getProductById(params.productId);
  }
}
