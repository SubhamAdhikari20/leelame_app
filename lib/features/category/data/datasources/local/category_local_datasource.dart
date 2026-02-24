// lib/features/category/data/datasources/local/category_local_datasource.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/services/hive/hive_service.dart';
import 'package:leelame/features/category/data/datasources/category_datasource.dart';
import 'package:leelame/features/category/data/models/category_hive_model.dart';

final categoryLocalDatasourceProvider = Provider<ICategoryLocalDatasource>((
  ref,
) {
  final hiveService = ref.read(hiveServiceProvider);
  return CategoryLocalDatasource(hiveService: hiveService);
});

class CategoryLocalDatasource implements ICategoryLocalDatasource {
  final HiveService _hiveService;

  CategoryLocalDatasource({required HiveService hiveService})
    : _hiveService = hiveService;

  @override
  Future<CategoryHiveModel?> createCategory(
    CategoryHiveModel categoryModel,
  ) async {
    final result = await _hiveService.createCategory(categoryModel);
    return Future.value(result);
  }

  @override
  Future<CategoryHiveModel?> updateCategory(
    CategoryHiveModel categoryModel,
  ) async {
    final result = await _hiveService.updateCategory(categoryModel);
    return Future.value(result);
  }

  @override
  Future<bool> deleteCategory(String categoryId) async {
    final result = await _hiveService.deleteCategory(categoryId);
    return Future.value(result);
  }

  @override
  Future<CategoryHiveModel?> getCategoryById(String categoryId) async {
    final result = await _hiveService.getCategoryById(categoryId);
    return Future.value(result);
  }

  @override
  Future<CategoryHiveModel?> getCategoryByCategoryName(
    String categoryName,
  ) async {
    final result = await _hiveService.getCategoryByCategoryName(categoryName);
    return Future.value(result);
  }

  @override
  Future<List<CategoryHiveModel>> getAllCategories() async {
    final result = await _hiveService.getAllCategories();
    return Future.value(result);
  }
}
