// lib/features/product/data/models/product_api_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leelame/features/product/domain/entities/product_entity.dart';

part "product_api_model.g.dart";

@JsonSerializable()
class ProductApiModel {
  @JsonKey(name: "_id")
  final String? id;
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

  ProductApiModel({
    this.id,
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

  // to Json
  Map<String, dynamic> toJson() {
    return _$ProductApiModelToJson(this);
  }

  // From JSON
  factory ProductApiModel.fromJson(Map<String, dynamic> json) {
    return _$ProductApiModelFromJson(json);
  }

  // to JSON List
  static List<Map<String, dynamic>> toJsonList(
    List<ProductApiModel> productModels,
  ) {
    return productModels.map((productModel) => productModel.toJson()).toList();
  }

  // from JSON List
  static List<ProductApiModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => ProductApiModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // to Entity
  ProductEntity toEntity() {
    return ProductEntity(
      productId: id,
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
  factory ProductApiModel.fromEntity(ProductEntity productEntity) {
    return ProductApiModel(
      id: productEntity.productId,
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
  static List<ProductEntity> toEntityList(List<ProductApiModel> productModels) {
    return productModels
        .map((productModel) => productModel.toEntity())
        .toList();
  }

  // from Entity List
  static List<ProductApiModel> fromEntityList(
    List<ProductEntity> productEntities,
  ) {
    return productEntities
        .map((productEntity) => ProductApiModel.fromEntity(productEntity))
        .toList();
  }
}
