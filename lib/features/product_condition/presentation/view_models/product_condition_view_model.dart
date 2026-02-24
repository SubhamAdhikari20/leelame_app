// lib/features/product_condition/presentation/view_models/product_condition_view_model.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/features/product_condition/domain/usecases/get_all_product_conditions_usecase.dart';
import 'package:leelame/features/product_condition/domain/usecases/get_product_condition_by_id_usecase.dart';
import 'package:leelame/features/product_condition/presentation/states/product_condition_state.dart';

final productConditionViewModelProvider =
    NotifierProvider<ProductConditionViewModel, ProductConditionState>(() {
      return ProductConditionViewModel();
    });

class ProductConditionViewModel extends Notifier<ProductConditionState> {
  late final GetAllProductConditionsUsecase _getAllProductConditionsUsecase;
  late final GetProductConditionByIdUsecase _getProductConditionByIdUsecase;

  @override
  ProductConditionState build() {
    _getAllProductConditionsUsecase = ref.read(
      getAllProductConditionsUsecaseProvider,
    );
    _getProductConditionByIdUsecase = ref.read(
      getProductConditionByIdUsecaseProvider,
    );
    return const ProductConditionState();
  }

  Future<void> getAllProductConditions() async {
    state = state.copyWith(
      productConditionStatus: ProductConditionStatus.loading,
    );
    final result = await _getAllProductConditionsUsecase();

    result.fold(
      (failure) => state = state.copyWith(
        productConditionStatus: ProductConditionStatus.error,
        errorMessage: failure.message,
      ),
      (productConditions) => state = state.copyWith(
        productConditionStatus: ProductConditionStatus.loaded,
        productConditions: productConditions,
      ),
    );
  }

  Future<void> getProductConditionById(String productConditionId) async {
    state = state.copyWith(
      productConditionStatus: ProductConditionStatus.loading,
    );

    final result = await _getProductConditionByIdUsecase(
      GetProductConditionByIdUsecaseParams(
        productConditionId: productConditionId,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        productConditionStatus: ProductConditionStatus.error,
        errorMessage: failure.message,
      ),
      (productCondition) => state = state.copyWith(
        productConditionStatus: ProductConditionStatus.loaded,
        selectedProductCondition: productCondition,
      ),
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void clearProductConditionList() {
    state = state.copyWith(productConditions: []);
  }

  void clearProductConditionStatus() {
    state = state.copyWith(
      productConditionStatus: ProductConditionStatus.initial,
    );
  }

  void clearSelectedProductCondition() {
    state = state.copyWith(selectedProductCondition: null);
  }
}
