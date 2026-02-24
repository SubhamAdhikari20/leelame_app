// lib/features/category/domain/entities/category_entity.dart
import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final String? categoryId;
  final String categoryName;
  final String? description;
  final String categoryStatus;

  const CategoryEntity({
    this.categoryId,
    required this.categoryName,
    this.description,
    required this.categoryStatus,
  });

  @override
  List<Object?> get props => [
    categoryId,
    categoryName,
    description,
    categoryStatus,
  ];

  CategoryEntity copyWith({
    String? categoryId,
    String? categoryName,
    String? description,
    String? categoryStatus,
  }) {
    return CategoryEntity(
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      description: description ?? this.description,
      categoryStatus: categoryStatus ?? this.categoryStatus,
    );
  }
}
