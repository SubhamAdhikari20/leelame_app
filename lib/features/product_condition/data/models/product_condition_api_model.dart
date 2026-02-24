// lib/features/product_condition/data/models/product_cndition_api_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leelame/features/product_condition/domain/entities/product_condition_entity.dart';

part "product_condition_api_model.g.dart";

@JsonSerializable()
class ProductConditionApiModel {
  @JsonKey(name: "_id")
  final String? id;
  final String productConditionName;
  final String? description;
  final String productConditionEnum;

  ProductConditionApiModel({
    this.id,
    required this.productConditionName,
    this.description,
    required this.productConditionEnum,
  });

  // to Json
  Map<String, dynamic> toJson() {
    return _$ProductConditionApiModelToJson(this);
  }

  // From JSON
  factory ProductConditionApiModel.fromJson(Map<String, dynamic> json) {
    return _$ProductConditionApiModelFromJson(json);
  }

  // to JSON List
  static List<Map<String, dynamic>> toJsonList(
    List<ProductConditionApiModel> productConditionModels,
  ) {
    return productConditionModels
        .map((productConditionModel) => productConditionModel.toJson())
        .toList();
  }

  // from JSON List
  static List<ProductConditionApiModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map(
          (json) =>
              ProductConditionApiModel.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  // to Entity
  ProductConditionEntity toEntity() {
    return ProductConditionEntity(
      productConditionId: id,
      productConditionName: productConditionName,
      description: description,
      productConditionEnum: productConditionEnum,
    );
  }

  // from Entity
  factory ProductConditionApiModel.fromEntity(
    ProductConditionEntity productConditionEntity,
  ) {
    return ProductConditionApiModel(
      id: productConditionEntity.productConditionId,
      productConditionName: productConditionEntity.productConditionName,
      description: productConditionEntity.description,
      productConditionEnum: productConditionEntity.productConditionEnum,
    );
  }

  // to Entity List
  static List<ProductConditionEntity> toEntityList(
    List<ProductConditionApiModel> productConditionModels,
  ) {
    return productConditionModels
        .map((productConditionModel) => productConditionModel.toEntity())
        .toList();
  }

  // from Entity List
  static List<ProductConditionApiModel> fromEntityList(
    List<ProductConditionEntity> productConditionEntities,
  ) {
    return productConditionEntities
        .map(
          (productConditionEntity) =>
              ProductConditionApiModel.fromEntity(productConditionEntity),
        )
        .toList();
  }
}
