// lib/features/product/data/models/product_hive_model.dart
import 'package:hive_ce/hive.dart';
import 'package:leelame/core/constants/hive_table_constant.dart';
import 'package:leelame/features/product/domain/entities/product_entity.dart';
import 'package:uuid/uuid.dart';

part "product_hive_model.g.dart";

@HiveType(typeId: HiveTableConstant.productsTypeId)
class ProductHiveModel extends HiveObject {
  @HiveField(0)
  final String? productId;

  @HiveField(1)
  final String? sellerId;

  @HiveField(2)
  final String productName;

  @HiveField(3)
  final String? description;

  @HiveField(4)
  final String? categoryId;

  @HiveField(5)
  final String? conditionId;

  @HiveField(6)
  final double commission;

  @HiveField(7)
  final double startPrice;

  @HiveField(8)
  final double currentBidPrice;

  @HiveField(9)
  final double bidIntervalPrice;

  @HiveField(10)
  final DateTime endDate;

  @HiveField(11)
  final List<String> productImageUrls;

  @HiveField(12)
  final bool isVerified;

  @HiveField(13)
  final bool isSoldOut;

  @HiveField(14)
  final String? soldToBuyerId;

  @HiveField(15)
  final List<String>? removedExistingProductImageUrls;

  ProductHiveModel({
    String? productId,
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
  }) : productId = productId ?? Uuid().v4();

  // Convert Model to Product Entity
  ProductEntity toEntity() {
    return ProductEntity(
      productId: productId,
      sellerId: sellerId,
      productName: productName,
      description: description,
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

  // Convert Product Entity to Model
  factory ProductHiveModel.fromEntity(ProductEntity productEntity) {
    return ProductHiveModel(
      productId: productEntity.productId,
      sellerId: productEntity.sellerId,
      productName: productEntity.productName,
      description: productEntity.description,
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

  // Convert List of Models to List of Product Entities
  static List<ProductEntity> toEntityList(
    List<ProductHiveModel> productModels,
  ) {
    return productModels
        .map((productModel) => productModel.toEntity())
        .toList();
  }

  ProductHiveModel copyWith({
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
    return ProductHiveModel(
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
