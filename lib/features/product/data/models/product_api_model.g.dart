// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductApiModel _$ProductApiModelFromJson(Map<String, dynamic> json) =>
    ProductApiModel(
      id: json['_id'] as String?,
      sellerId: json['sellerId'] as String?,
      productName: json['productName'] as String,
      description: json['description'] as String?,
      categoryId: json['categoryId'] as String?,
      conditionId: json['conditionId'] as String?,
      commission: (json['commission'] as num).toDouble(),
      startPrice: (json['startPrice'] as num).toDouble(),
      currentBidPrice: (json['currentBidPrice'] as num).toDouble(),
      bidIntervalPrice: (json['bidIntervalPrice'] as num).toDouble(),
      endDate: DateTime.parse(json['endDate'] as String),
      productImageUrls: (json['productImageUrls'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      buyNowPrice: (json['buyNowPrice'] as num?)?.toDouble(),
      isVerified: json['isVerified'] as bool,
      isSoldOut: json['isSoldOut'] as bool,
      soldToBuyerId: json['soldToBuyerId'] as String?,
      removedExistingProductImageUrls:
          (json['removedExistingProductImageUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
    );

Map<String, dynamic> _$ProductApiModelToJson(
  ProductApiModel instance,
) => <String, dynamic>{
  '_id': instance.id,
  'sellerId': instance.sellerId,
  'productName': instance.productName,
  'description': instance.description,
  'categoryId': instance.categoryId,
  'conditionId': instance.conditionId,
  'commission': instance.commission,
  'startPrice': instance.startPrice,
  'currentBidPrice': instance.currentBidPrice,
  'bidIntervalPrice': instance.bidIntervalPrice,
  'endDate': instance.endDate.toIso8601String(),
  'productImageUrls': instance.productImageUrls,
  'buyNowPrice': instance.buyNowPrice,
  'isVerified': instance.isVerified,
  'isSoldOut': instance.isSoldOut,
  'soldToBuyerId': instance.soldToBuyerId,
  'removedExistingProductImageUrls': instance.removedExistingProductImageUrls,
};
