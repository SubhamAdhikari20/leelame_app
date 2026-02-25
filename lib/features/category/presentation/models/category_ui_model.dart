// lib/features/category/presentation/models/category_ui_model.dart
import 'package:leelame/features/category/domain/entities/category_entity.dart';

class CategoryUiModel {
  final String? categoryId;
  final String categoryName;
  final String? description;
  final String categoryStatus;

  CategoryUiModel({
    this.categoryId,
    required this.categoryName,
    this.description,
    required this.categoryStatus,
  });

  // to Entity
  CategoryEntity toEntity() {
    return CategoryEntity(
      categoryId: categoryId,
      categoryName: categoryName,
      description: description,
      categoryStatus: categoryStatus,
    );
  }

  // from Entity
  factory CategoryUiModel.fromEntity(CategoryEntity categoryEntity) {
    return CategoryUiModel(
      categoryId: categoryEntity.categoryId,
      categoryName: categoryEntity.categoryName,
      description: categoryEntity.description,
      categoryStatus: categoryEntity.categoryStatus,
    );
  }

  // to Entity List
  static List<CategoryEntity> toEntityList(
    List<CategoryUiModel> categoryModels,
  ) {
    return categoryModels
        .map((categoryModel) => categoryModel.toEntity())
        .toList();
  }

  // from Entity List
  static List<CategoryUiModel> fromEntityList(
    List<CategoryEntity> categoryEntities,
  ) {
    return categoryEntities
        .map((categoryEntity) => CategoryUiModel.fromEntity(categoryEntity))
        .toList();
  }

  CategoryUiModel copyWith({
    String? categoryId,
    String? categoryName,
    String? description,
    String? categoryStatus,
  }) {
    return CategoryUiModel(
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      description: description ?? this.description,
      categoryStatus: categoryStatus ?? this.categoryStatus,
    );
  }
}
