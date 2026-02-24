// lib/features/product_condition/presentation/states/product_condition_state.dart
import 'package:equatable/equatable.dart';
import 'package:leelame/features/product_condition/domain/entities/product_condition_entity.dart';

enum ProductConditionStatus {
  initial,
  loading,
  loaded,
  error,
  created,
  updated,
  deleted,
}

class ProductConditionState extends Equatable {
  final ProductConditionStatus productConditionStatus;
  final List<ProductConditionEntity> productConditions;
  final ProductConditionEntity? selectedProductCondition;
  final String? errorMessage;

  const ProductConditionState({
    this.productConditionStatus = ProductConditionStatus.initial,
    this.productConditions = const [],
    this.selectedProductCondition,
    this.errorMessage,
  });

  ProductConditionState copyWith({
    ProductConditionStatus? productConditionStatus,
    List<ProductConditionEntity>? productConditions,
    ProductConditionEntity? selectedProductCondition,
    String? errorMessage,
  }) {
    return ProductConditionState(
      productConditionStatus:
          productConditionStatus ?? this.productConditionStatus,
      productConditions: productConditions ?? this.productConditions,
      selectedProductCondition:
          selectedProductCondition ?? this.selectedProductCondition,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    productConditionStatus,
    productConditions,
    selectedProductCondition,
    errorMessage,
  ];
}
