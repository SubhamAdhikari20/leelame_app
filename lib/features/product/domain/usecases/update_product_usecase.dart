// lib/features/product/domain/usecases/update_product_usecase.dart
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/core/usecases/app_usecase.dart';
import 'package:leelame/features/product/data/repositories/product_repository.dart';
import 'package:leelame/features/product/domain/entities/product_entity.dart';
import 'package:leelame/features/product/domain/repositories/product_repository.dart';

class UpdateProductUsecaseParams extends Equatable {
  final String productId;
  final String? productName;
  final String? description;
  final String? sellerId;
  final String? categoryId;
  final String? conditionId;
  final double? startPrice;
  final double? currentBidPrice;
  final double? bidIntervalPrice;
  final DateTime? endDate;
  final List<File>? productImages;
  final String? imageSubFolder;

  const UpdateProductUsecaseParams({
    required this.productId,
    this.productName,
    this.description,
    this.sellerId,
    this.categoryId,
    this.conditionId,
    this.startPrice,
    this.currentBidPrice,
    this.bidIntervalPrice,
    this.endDate,
    this.productImages,
    this.imageSubFolder,
  });

  @override
  List<Object?> get props => [
    productId,
    productName,
    description,
    sellerId,
    categoryId,
    conditionId,
    startPrice,
    currentBidPrice,
    bidIntervalPrice,
    endDate,
    productImages,
    imageSubFolder,
  ];
}

final updateProductUsecaseProvider = Provider<UpdateProductUsecase>((ref) {
  final productRepository = ref.read(productRepositoryProvider);
  return UpdateProductUsecase(productRepository: productRepository);
});

class UpdateProductUsecase
    implements UsecaseWithParams<ProductEntity, UpdateProductUsecaseParams> {
  final IProductRepository _productRepository;

  UpdateProductUsecase({required IProductRepository productRepository})
    : _productRepository = productRepository;

  @override
  Future<Either<Failures, ProductEntity>> call(
    UpdateProductUsecaseParams params,
  ) async {
    final productResult = await _productRepository.getProductById(
      params.productId,
    );

    return productResult.fold(
      (failure) {
        return Left(failure);
      },
      (productEntity) async {
        final updatedProduct = productEntity.copyWith(
          productName: params.productName,
          description: params.description,
          sellerId: params.sellerId,
          categoryId: params.categoryId,
          conditionId: params.conditionId,
          startPrice: params.startPrice,
          currentBidPrice: params.currentBidPrice,
          bidIntervalPrice: params.bidIntervalPrice,
          endDate: params.endDate,
        );

        return await _productRepository.updateProduct(
          productEntity: updatedProduct,
          productImages: params.productImages,
          imageSubFolder: params.imageSubFolder,
        );
      },
    );
  }
}
