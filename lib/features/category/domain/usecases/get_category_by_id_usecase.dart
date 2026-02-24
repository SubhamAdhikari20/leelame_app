// lib/features/category/domain/usecases/get_category_by_id_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/core/usecases/app_usecase.dart';
import 'package:leelame/features/category/data/repositories/category_repository.dart';
import 'package:leelame/features/category/domain/entities/category_entity.dart';
import 'package:leelame/features/category/domain/repositories/category_repository.dart';

class GetCategoryByIdUsecaseParams extends Equatable {
  final String categoryId;

  const GetCategoryByIdUsecaseParams({required this.categoryId});

  @override
  List<Object?> get props => [categoryId];
}

final getCategoryByIdUsecaseProvider = Provider<GetCategoryByIdUsecase>((ref) {
  final categoryRepository = ref.read(categoryRepositoryProvider);
  return GetCategoryByIdUsecase(categoryRepository: categoryRepository);
});

class GetCategoryByIdUsecase
    implements UsecaseWithParams<CategoryEntity, GetCategoryByIdUsecaseParams> {
  final ICategoryRepository _categoryRepository;

  GetCategoryByIdUsecase({required ICategoryRepository categoryRepository})
    : _categoryRepository = categoryRepository;

  @override
  Future<Either<Failures, CategoryEntity>> call(
    GetCategoryByIdUsecaseParams params,
  ) async {
    return await _categoryRepository.getCategoryById(params.categoryId);
  }
}
