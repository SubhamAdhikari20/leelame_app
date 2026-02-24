// lib/features/product_condition/domain/entities/product_condition_entity.dart
import 'package:equatable/equatable.dart';

class ProductConditionEntity extends Equatable {
  final String? productConditionId;
  final String productConditionName;
  final String? description;
  final String productConditionEnum;

  const ProductConditionEntity({
    this.productConditionId,
    required this.productConditionName,
    this.description,
    required this.productConditionEnum,
  });

  @override
  List<Object?> get props => [
    productConditionId,
    productConditionName,
    description,
    productConditionEnum,
  ];

  ProductConditionEntity copyWith({
    String? productConditionId,
    String? productConditionName,
    String? description,
    String? productConditionEnum,
  }) {
    return ProductConditionEntity(
      productConditionId: productConditionId ?? this.productConditionId,
      productConditionName: productConditionName ?? this.productConditionName,
      description: description ?? this.description,
      productConditionEnum: productConditionEnum ?? this.productConditionEnum,
    );
  }
}
