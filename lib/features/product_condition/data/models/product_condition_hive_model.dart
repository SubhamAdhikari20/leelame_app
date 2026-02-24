// lib/features/product_condition/data/models/product_condition_hive_model.dart
import 'package:hive_ce/hive.dart';
import 'package:leelame/core/constants/hive_table_constant.dart';
import 'package:leelame/features/product_condition/domain/entities/product_condition_entity.dart';
import 'package:uuid/uuid.dart';

part "product_condition_hive_model.g.dart";

@HiveType(typeId: HiveTableConstant.productConditionsTypeId)
class ProductConditionHiveModel extends HiveObject {
  @HiveField(0)
  final String? productConditionId;

  @HiveField(1)
  final String productConditionName;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final String productConditionEnum;

  ProductConditionHiveModel({
    String? productConditionId,
    required this.productConditionName,
    this.description,
    required this.productConditionEnum,
  }) : productConditionId = productConditionId ?? Uuid().v4();

  // Convert Model to ProductCondition Entity
  ProductConditionEntity toEntity() {
    return ProductConditionEntity(
      productConditionId: productConditionId,
      productConditionName: productConditionName,
      description: description,
      productConditionEnum: productConditionEnum,
    );
  }

  // Convert ProductCondition Entity to Model
  factory ProductConditionHiveModel.fromEntity(
    ProductConditionEntity productConditionEntity,
  ) {
    return ProductConditionHiveModel(
      productConditionId: productConditionEntity.productConditionId,
      productConditionName: productConditionEntity.productConditionName,
      description: productConditionEntity.description,
      productConditionEnum: productConditionEntity.productConditionEnum,
    );
  }

  // Convert List of Models to List of ProductCondition Entities
  static List<ProductConditionEntity> toEntityList(
    List<ProductConditionHiveModel> productConditionModels,
  ) {
    return productConditionModels
        .map((productConditionModel) => productConditionModel.toEntity())
        .toList();
  }

  ProductConditionHiveModel copyWith({
    String? productConditionId,
    String? productConditionName,
    String? description,
    String? productConditionEnum,
  }) {
    return ProductConditionHiveModel(
      productConditionId: productConditionId ?? this.productConditionId,
      productConditionName: productConditionName ?? this.productConditionName,
      description: description ?? this.description,
      productConditionEnum: productConditionEnum ?? this.productConditionEnum,
    );
  }
}
