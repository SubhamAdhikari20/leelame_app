// lib/features/category/data/datasources/category_datasource.dart
import 'package:leelame/features/category/data/models/category_api_model.dart';
import 'package:leelame/features/category/data/models/category_hive_model.dart';

abstract interface class ICategoryLocalDatasource {
  Future<CategoryHiveModel?> createCategory(CategoryHiveModel categoryModel);
  Future<CategoryHiveModel?> updateCategory(CategoryHiveModel categoryModel);
  Future<CategoryHiveModel?> getCategoryById(String categoryId);
  Future<CategoryHiveModel?> getCategoryByCategoryName(String categoryName);
  Future<bool> deleteCategory(String categoryId);
  Future<List<CategoryHiveModel>> getAllCategories();
}

abstract interface class ICategoryRemoteDatasource {
  Future<CategoryApiModel?> createCategory(CategoryApiModel categoryModel);
  Future<CategoryApiModel?> updateCategory(CategoryApiModel categoryModel);
  Future<CategoryApiModel?> getCategoryById(String categoryId);
  Future<bool> deleteCategory(String categoryId);
  Future<List<CategoryApiModel>> getAllCategories();
}
