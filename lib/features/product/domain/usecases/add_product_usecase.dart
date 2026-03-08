// lib/features/product/domain/usecases/add_product_usecase.dart
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/core/usecases/app_usecase.dart';
import 'package:leelame/features/product/data/repositories/product_repository.dart';
import 'package:leelame/features/product/domain/entities/product_entity.dart';
import 'package:leelame/features/product/domain/repositories/product_repository.dart';

class AddProductUsecaseParams extends Equatable {
  final String productName;
  final String? description;
  final String? sellerId;
  final String? categoryId;
  final String? conditionId;
  final double startPrice;
  final double bidIntervalPrice;
  final DateTime endDate;
  final double? buyNowPrice;
  final List<File>? productImages;
  final String? imageSubFolder;

  const AddProductUsecaseParams({
    this.sellerId,
    required this.productName,
    this.description,
    this.categoryId,
    this.conditionId,
    required this.startPrice,
    required this.bidIntervalPrice,
    required this.endDate,
    this.buyNowPrice,
    this.productImages,
    this.imageSubFolder,
  });

  @override
  List<Object?> get props => [
    sellerId,
    productName,
    description,
    categoryId,
    conditionId,
    startPrice,
    bidIntervalPrice,
    endDate,
    buyNowPrice,
    productImages,
    imageSubFolder,
  ];
}

final addProductUsecaseProvider = Provider<AddProductUsecase>((ref) {
  final productRepository = ref.read(productRepositoryProvider);
  return AddProductUsecase(productRepository: productRepository);
});

class AddProductUsecase
    implements UsecaseWithParams<ProductEntity, AddProductUsecaseParams> {
  final IProductRepository _productRepository;

  AddProductUsecase({required IProductRepository productRepository})
    : _productRepository = productRepository;

  @override
  Future<Either<Failures, ProductEntity>> call(
    AddProductUsecaseParams params,
  ) async {
    final productEntity = ProductEntity(
      sellerId: params.sellerId,
      productName: params.productName,
      description: params.description,
      categoryId: params.categoryId,
      conditionId: params.conditionId,
      commission: 0,
      startPrice: params.startPrice,
      currentBidPrice: params.startPrice,
      bidIntervalPrice: params.bidIntervalPrice,
      endDate: params.endDate,
      productImageUrls: [],
      buyNowPrice: params.buyNowPrice,
      isVerified: false,
      isSoldOut: false,
    );

    return await _productRepository.createProduct(
      productEntity: productEntity,
      productImages: params.productImages,
      imageSubFolder: params.imageSubFolder,
    );
  }
}
