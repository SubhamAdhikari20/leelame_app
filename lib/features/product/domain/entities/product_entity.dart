// lib/features/product/domain/entities/product_entity.dart
import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
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

  const ProductEntity({
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

  @override
  List<Object?> get props => [
    productId,
    sellerId,
    productName,
    description,
    categoryId,
    conditionId,
    commission,
    startPrice,
    currentBidPrice,
    bidIntervalPrice,
    endDate,
    productImageUrls,
    isVerified,
    isSoldOut,
    soldToBuyerId,
    removedExistingProductImageUrls,
  ];

  ProductEntity copyWith({
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
    return ProductEntity(
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
