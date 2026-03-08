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
  final double? buyNowPrice;
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
    this.buyNowPrice,
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
    return ProductApiModel(
      id: json['_id'] as String?,
      sellerId: json['sellerId'] as String?,
      productName: json['productName'] as String,
      description: json['description'] as String?,
      categoryId: json['categoryId'] as String?,
      conditionId: json['conditionId'] as String?,
      commission: (json['commission'] as num? ?? 0.0).toDouble(),
      startPrice: (json['startPrice'] as num? ?? 0.0).toDouble(),
      currentBidPrice: (json['currentBidPrice'] as num? ?? 0.0).toDouble(),
      bidIntervalPrice: (json['bidIntervalPrice'] as num? ?? 0.0).toDouble(),
      endDate: json['endDate'] == null
          ? DateTime.now()
          : DateTime.parse(json['endDate'] as String),
      productImageUrls:
          (json['productImageUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      buyNowPrice: (json['buyNowPrice'] as num? ?? 0.0).toDouble(),
      isVerified: json['isVerified'] as bool? ?? false,
      isSoldOut: json['isSoldOut'] as bool? ?? false,
      soldToBuyerId: json['soldToBuyerId'] as String?,
      removedExistingProductImageUrls:
          (json['removedExistingProductImageUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
    );
  }

  // // From JSON
  // factory ProductApiModel.fromJson(Map<String, dynamic> json) {
  //   return _$ProductApiModelFromJson(json);
  // }

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
      buyNowPrice: buyNowPrice,
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
      buyNowPrice: productEntity.buyNowPrice,
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

  ProductApiModel copyWith({
    String? id,
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
    double? buyNowPrice,
    bool? isVerified,
    bool? isSoldOut,
    String? soldToBuyerId,
    List<String>? removedExistingProductImageUrls,
  }) {
    return ProductApiModel(
      id: id ?? this.id,
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
      buyNowPrice: buyNowPrice ?? this.buyNowPrice,
      isVerified: isVerified ?? this.isVerified,
      isSoldOut: isSoldOut ?? this.isSoldOut,
      soldToBuyerId: soldToBuyerId ?? this.soldToBuyerId,
      removedExistingProductImageUrls:
          removedExistingProductImageUrls ??
          this.removedExistingProductImageUrls,
    );
  }
}
