// lib/features/category/data/models/category_api_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leelame/features/category/domain/entities/category_entity.dart';

part "category_api_model.g.dart";

@JsonSerializable()
class CategoryApiModel {
  @JsonKey(name: "_id")
  final String? id;
  final String categoryName;
  final String? description;
  final String categoryStatus;

  CategoryApiModel({
    this.id,
    required this.categoryName,
    this.description,
    required this.categoryStatus,
  });

  // to Json
  Map<String, dynamic> toJson() {
    return _$CategoryApiModelToJson(this);
  }

  // From JSON
  factory CategoryApiModel.fromJson(Map<String, dynamic> json) {
    return _$CategoryApiModelFromJson(json);
  }

  // to JSON List
  static List<Map<String, dynamic>> toJsonList(
    List<CategoryApiModel> categoryModels,
  ) {
    return categoryModels
        .map((categoryModel) => categoryModel.toJson())
        .toList();
  }

  // from JSON List
  static List<CategoryApiModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => CategoryApiModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // to Entity
  CategoryEntity toEntity() {
    return CategoryEntity(
      categoryId: id,
      categoryName: categoryName,
      description: description,
      categoryStatus: categoryStatus,
    );
  }

  // from Entity
  factory CategoryApiModel.fromEntity(CategoryEntity categoryEntity) {
    return CategoryApiModel(
      id: categoryEntity.categoryId,
      categoryName: categoryEntity.categoryName,
      description: categoryEntity.description,
      categoryStatus: categoryEntity.categoryStatus,
    );
  }

  // to Entity List
  static List<CategoryEntity> toEntityList(
    List<CategoryApiModel> categoryModels,
  ) {
    return categoryModels
        .map((categoryModel) => categoryModel.toEntity())
        .toList();
  }

  // from Entity List
  static List<CategoryApiModel> fromEntityList(
    List<CategoryEntity> categoryEntities,
  ) {
    return categoryEntities
        .map((categoryEntity) => CategoryApiModel.fromEntity(categoryEntity))
        .toList();
  }
}
