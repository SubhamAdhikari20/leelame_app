// lib/features/product/presentation/models/product_ui_model.dart
import 'package:leelame/features/product/domain/entities/product_entity.dart';

class ProductUiModel {
  final String? productId;
  final String? sellerId;
  final String productName;
  final String? description;
  final String? categoryId;
  final String? conditionId;
  final double commission;
  final double startPrice;
  final double currentBidPrice;
  final double bidIntervalPrice;
  final DateTime endDate;
  final List<String> productImageUrls;
  final bool isVerified;
  final bool isSoldOut;
  final String? soldToBuyerId;
  final List<String>? removedExistingProductImageUrls;

  ProductUiModel({
    this.productId,
    this.sellerId,
    required this.productName,
    this.description,
    this.categoryId,
    this.conditionId,
    required this.commission,
    required this.startPrice,
    required this.currentBidPrice,
    required this.bidIntervalPrice,
    required this.endDate,
    required this.productImageUrls,
    required this.isVerified,
    required this.isSoldOut,
    this.soldToBuyerId,
    this.removedExistingProductImageUrls,
  });

  // to Entity
  ProductEntity toEntity() {
    return ProductEntity(
      productId: productId,
      productName: productName,
      description: description,
      sellerId: sellerId,
      categoryId: categoryId,
      conditionId: conditionId,
      commission: commission,
      startPrice: startPrice,
      currentBidPrice: currentBidPrice,
      bidIntervalPrice: bidIntervalPrice,
      endDate: endDate,
      productImageUrls: productImageUrls,
      isVerified: isVerified,
      isSoldOut: isSoldOut,
      soldToBuyerId: soldToBuyerId,
      removedExistingProductImageUrls: removedExistingProductImageUrls,
    );
  }

  // from Entity
  factory ProductUiModel.fromEntity(ProductEntity productEntity) {
    return ProductUiModel(
      productId: productEntity.productId,
      productName: productEntity.productName,
      description: productEntity.description,
      sellerId: productEntity.sellerId,
      categoryId: productEntity.categoryId,
      conditionId: productEntity.conditionId,
      commission: productEntity.commission,
      startPrice: productEntity.startPrice,
      currentBidPrice: productEntity.currentBidPrice,
      bidIntervalPrice: productEntity.bidIntervalPrice,
      endDate: productEntity.endDate,
      productImageUrls: productEntity.productImageUrls,
      isVerified: productEntity.isVerified,
      isSoldOut: productEntity.isSoldOut,
      soldToBuyerId: productEntity.soldToBuyerId,
      removedExistingProductImageUrls:
          productEntity.removedExistingProductImageUrls,
    );
  }

  // to Entity List
  static List<ProductEntity> toEntityList(List<ProductUiModel> productModels) {
    return productModels
        .map((productModel) => productModel.toEntity())
        .toList();
  }

  // from Entity List
  static List<ProductUiModel> fromEntityList(
    List<ProductEntity> productEntities,
  ) {
    return productEntities
        .map((productEntity) => ProductUiModel.fromEntity(productEntity))
        .toList();
  }

  ProductUiModel copyWith({
    String? productId,
    String? sellerId,
    String? productName,
    String? description,
    String? categoryId,
    String? conditionId,
    double? commission,
    double? startPrice,
    double? currentBidPrice,
    double? bidIntervalPrice,
    DateTime? endDate,
    List<String>? productImageUrls,
    bool? isVerified,
    bool? isSoldOut,
    String? soldToBuyerId,
    List<String>? removedExistingProductImageUrls,
  }) {
    return ProductUiModel(
      productId: productId ?? this.productId,
      sellerId: sellerId ?? this.sellerId,
      productName: productName ?? this.productName,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      conditionId: conditionId ?? this.conditionId,
      commission: commission ?? this.commission,
      startPrice: startPrice ?? this.startPrice,
      currentBidPrice: currentBidPrice ?? this.currentBidPrice,
      bidIntervalPrice: bidIntervalPrice ?? this.bidIntervalPrice,
      endDate: endDate ?? this.endDate,
      productImageUrls: productImageUrls ?? this.productImageUrls,
      isVerified: isVerified ?? this.isVerified,
      isSoldOut: isSoldOut ?? this.isSoldOut,
      soldToBuyerId: soldToBuyerId ?? this.soldToBuyerId,
      removedExistingProductImageUrls:
          removedExistingProductImageUrls ??
          this.removedExistingProductImageUrls,
    );
  }
}
