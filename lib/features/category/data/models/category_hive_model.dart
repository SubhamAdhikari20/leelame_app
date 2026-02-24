// lib/features/category/data/models/category_hive_model.dart
import 'package:hive_ce/hive.dart';
import 'package:leelame/core/constants/hive_table_constant.dart';
import 'package:leelame/features/category/domain/entities/category_entity.dart';
import 'package:uuid/uuid.dart';

part "category_hive_model.g.dart";

@HiveType(typeId: HiveTableConstant.categoriesTypeId)
class CategoryHiveModel extends HiveObject {
  @HiveField(0)
  final String? categoryId;

  @HiveField(1)
  final String categoryName;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final String categoryStatus;

  CategoryHiveModel({
    String? categoryId,
    required this.categoryName,
    this.description,
    required this.categoryStatus,
  }) : categoryId = categoryId ?? Uuid().v4();

  // Convert Model to Category Entity
  CategoryEntity toEntity() {
    return CategoryEntity(
      categoryId: categoryId,
      categoryName: categoryName,
      description: description,
      categoryStatus: categoryStatus,
    );
  }

  // Convert Category Entity to Model
  factory CategoryHiveModel.fromEntity(CategoryEntity categoryEntity) {
    return CategoryHiveModel(
      categoryId: categoryEntity.categoryId,
      categoryName: categoryEntity.categoryName,
      description: categoryEntity.description,
      categoryStatus: categoryEntity.categoryStatus,
    );
  }

  // Convert List of Models to List of Category Entities
  static List<CategoryEntity> toEntityList(
    List<CategoryHiveModel> categoryModels,
  ) {
    return categoryModels
        .map((categoryModel) => categoryModel.toEntity())
        .toList();
  }

  CategoryHiveModel copyWith({
    String? categoryId,
    String? categoryName,
    String? description,
    String? categoryStatus,
  }) {
    return CategoryHiveModel(
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      description: description ?? this.description,
      categoryStatus: categoryStatus ?? this.categoryStatus,
    );
  }
}
