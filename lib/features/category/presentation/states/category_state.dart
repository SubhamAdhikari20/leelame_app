// lib/features/category/presentation/states/category_state.dart
import 'package:equatable/equatable.dart';
import 'package:leelame/features/category/domain/entities/category_entity.dart';

enum CategoryStatus {
  initial,
  loading,
  loaded,
  error,
  created,
  updated,
  deleted,
}

class CategoryState extends Equatable {
  final CategoryStatus categoryStatus;
  final List<CategoryEntity> categories;
  final CategoryEntity? selectedCategory;
  final String? errorMessage;

  const CategoryState({
    this.categoryStatus = CategoryStatus.initial,
    this.categories = const [],
    this.selectedCategory,
    this.errorMessage,
  });

  CategoryState copyWith({
    CategoryStatus? categoryStatus,
    List<CategoryEntity>? categories,
    CategoryEntity? selectedCategory,
    String? errorMessage,
  }) {
    return CategoryState(
      categoryStatus: categoryStatus ?? this.categoryStatus,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    categoryStatus,
    categories,
    selectedCategory,
    errorMessage,
  ];
}
