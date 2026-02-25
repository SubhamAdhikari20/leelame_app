// lib/features/product_condition/presentation/models/product_cndition_ui_model.dart
import 'package:leelame/features/product_condition/domain/entities/product_condition_entity.dart';

class ProductConditionUiModel {
  final String? productConditionId;
  final String productConditionName;
  final String? description;
  final String productConditionEnum;

  ProductConditionUiModel({
    this.productConditionId,
    required this.productConditionName,
    this.description,
    required this.productConditionEnum,
  });

  // to Entity
  ProductConditionEntity toEntity() {
    return ProductConditionEntity(
      productConditionId: productConditionId,
      productConditionName: productConditionName,
      description: description,
      productConditionEnum: productConditionEnum,
    );
  }

  // from Entity
  factory ProductConditionUiModel.fromEntity(
    ProductConditionEntity productConditionEntity,
  ) {
    return ProductConditionUiModel(
      productConditionId: productConditionEntity.productConditionId,
      productConditionName: productConditionEntity.productConditionName,
      description: productConditionEntity.description,
      productConditionEnum: productConditionEntity.productConditionEnum,
    );
  }

  // to Entity List
  static List<ProductConditionEntity> toEntityList(
    List<ProductConditionUiModel> productConditionModels,
  ) {
    return productConditionModels
        .map((productConditionModel) => productConditionModel.toEntity())
        .toList();
  }

  // from Entity List
  static List<ProductConditionUiModel> fromEntityList(
    List<ProductConditionEntity> productConditionEntities,
  ) {
    return productConditionEntities
        .map(
          (productConditionEntity) =>
              ProductConditionUiModel.fromEntity(productConditionEntity),
        )
        .toList();
  }

  ProductConditionUiModel copyWith({
    String? productConditionId,
    String? productConditionName,
    String? description,
    String? productConditionEnum,
  }) {
    return ProductConditionUiModel(
      productConditionId: productConditionId ?? this.productConditionId,
      productConditionName: productConditionName ?? this.productConditionName,
      description: description ?? this.description,
      productConditionEnum: productConditionEnum ?? this.productConditionEnum,
    );
  }
}
