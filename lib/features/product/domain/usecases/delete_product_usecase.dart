// lib/features/product/domain/usecases/delete_product_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/core/usecases/app_usecase.dart';
import 'package:leelame/features/product/data/repositories/product_repository.dart';
import 'package:leelame/features/product/domain/repositories/product_repository.dart';

class DeleteProductUsecaseParams extends Equatable {
  final String productId;

  const DeleteProductUsecaseParams({required this.productId});

  @override
  List<Object?> get props => [productId];
}

final deleteProductUsecaseProvider = Provider<DeleteProductUsecase>((ref) {
  final productRepository = ref.read(productRepositoryProvider);
  return DeleteProductUsecase(productRepository: productRepository);
});

class DeleteProductUsecase
    implements UsecaseWithParams<bool, DeleteProductUsecaseParams> {
  final IProductRepository _productRepository;

  DeleteProductUsecase({required IProductRepository productRepository})
    : _productRepository = productRepository;

  @override
  Future<Either<Failures, bool>> call(DeleteProductUsecaseParams params) async {
    return await _productRepository.deleteProduct(params.productId);
  }
}
