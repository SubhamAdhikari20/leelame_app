// lib/features/product/domain/usecases/get_all_products_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/core/usecases/app_usecase.dart';
import 'package:leelame/features/product/data/repositories/product_repository.dart';
import 'package:leelame/features/product/domain/entities/product_entity.dart';
import 'package:leelame/features/product/domain/repositories/product_repository.dart';

final getAllProductsUsecaseProvider = Provider<GetAllProductsUsecase>((ref) {
  final productRepository = ref.read(productRepositoryProvider);
  return GetAllProductsUsecase(productRepository: productRepository);
});

class GetAllProductsUsecase
    implements UsecaseWithoutParams<List<ProductEntity>> {
  final IProductRepository _productRepository;

  GetAllProductsUsecase({required IProductRepository productRepository})
    : _productRepository = productRepository;

  @override
  Future<Either<Failures, List<ProductEntity>>> call() async {
    return await _productRepository.getAllProducts();
  }
}
