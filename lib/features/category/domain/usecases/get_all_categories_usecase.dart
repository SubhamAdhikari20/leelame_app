// lib/features/category/domain/usecases/get_all_categories_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/core/usecases/app_usecase.dart';
import 'package:leelame/features/category/data/repositories/category_repository.dart';
import 'package:leelame/features/category/domain/entities/category_entity.dart';
import 'package:leelame/features/category/domain/repositories/category_repository.dart';

final getAllCategoriesUsecaseProvider = Provider<GetAllCategoriesUsecase>((
  ref,
) {
  final categoryRepository = ref.read(categoryRepositoryProvider);
  return GetAllCategoriesUsecase(categoryRepository: categoryRepository);
});

class GetAllCategoriesUsecase
    implements UsecaseWithoutParams<List<CategoryEntity>> {
  final ICategoryRepository _categoryRepository;

  GetAllCategoriesUsecase({required ICategoryRepository categoryRepository})
    : _categoryRepository = categoryRepository;

  @override
  Future<Either<Failures, List<CategoryEntity>>> call() async {
    return await _categoryRepository.getAllCategories();
  }
}
