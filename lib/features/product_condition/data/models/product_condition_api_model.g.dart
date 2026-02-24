// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_condition_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductConditionApiModel _$ProductConditionApiModelFromJson(
  Map<String, dynamic> json,
) => ProductConditionApiModel(
  id: json['_id'] as String?,
  productConditionName: json['productConditionName'] as String,
  description: json['description'] as String?,
  productConditionEnum: json['productConditionEnum'] as String,
);

Map<String, dynamic> _$ProductConditionApiModelToJson(
  ProductConditionApiModel instance,
) => <String, dynamic>{
  '_id': instance.id,
  'productConditionName': instance.productConditionName,
  'description': instance.description,
  'productConditionEnum': instance.productConditionEnum,
};
