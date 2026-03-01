// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bid_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BidApiModel _$BidApiModelFromJson(Map<String, dynamic> json) => BidApiModel(
  id: json['_id'] as String?,
  productId: json['productId'] as String?,
  buyerId: json['buyerId'] as String?,
  bidAmount: (json['bidAmount'] as num).toDouble(),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$BidApiModelToJson(BidApiModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'productId': instance.productId,
      'buyerId': instance.buyerId,
      'bidAmount': instance.bidAmount,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
