// lib/features/category/presentation/view_models/category_view_model.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/features/category/domain/usecases/get_all_categories_usecase.dart';
import 'package:leelame/features/category/domain/usecases/get_category_by_id_usecase.dart';
import 'package:leelame/features/category/presentation/states/category_state.dart';

final categoryViewModelProvider =
    NotifierProvider<CategoryViewModel, CategoryState>(() {
      return CategoryViewModel();
    });

class CategoryViewModel extends Notifier<CategoryState> {
  late final GetAllCategoriesUsecase _getAllCategoriesUsecase;
  late final GetCategoryByIdUsecase _getCategoryByIdUsecase;

  @override
  CategoryState build() {
    _getAllCategoriesUsecase = ref.read(getAllCategoriesUsecaseProvider);
    _getCategoryByIdUsecase = ref.read(getCategoryByIdUsecaseProvider);
    return const CategoryState();
  }

  Future<void> getAllCategories() async {
    state = state.copyWith(categoryStatus: CategoryStatus.loading);
    final result = await _getAllCategoriesUsecase();

    result.fold(
      (failure) => state = state.copyWith(
        categoryStatus: CategoryStatus.error,
        errorMessage: failure.message,
      ),
      (categories) => state = state.copyWith(
        categoryStatus: CategoryStatus.loaded,
        categories: categories,
      ),
    );
  }

  Future<void> getCategoryById(String categoryId) async {
    state = state.copyWith(categoryStatus: CategoryStatus.loading);

    final result = await _getCategoryByIdUsecase(
      GetCategoryByIdUsecaseParams(categoryId: categoryId),
    );

    result.fold(
      (failure) => state = state.copyWith(
        categoryStatus: CategoryStatus.error,
        errorMessage: failure.message,
      ),
      (category) => state = state.copyWith(
        categoryStatus: CategoryStatus.loaded,
        selectedCategory: category,
      ),
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void clearSelectedCategory() {
    state = state.copyWith(selectedCategory: null);
  }
}
