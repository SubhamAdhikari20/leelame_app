// lib/features/product/presentation/view_models/product_view_model.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/features/product/domain/usecases/get_all_products_by_buyer_id_usecase.dart';
import 'package:leelame/features/product/domain/usecases/get_all_products_by_seller_id_usecase.dart';
import 'package:leelame/features/product/domain/usecases/get_all_products_usecase.dart';
import 'package:leelame/features/product/domain/usecases/get_product_by_id_usecase.dart';
import 'package:leelame/features/product/presentation/states/product_state.dart';

final productViewModelProvider =
    NotifierProvider<ProductViewModel, ProductState>(() {
      return ProductViewModel();
    });

class ProductViewModel extends Notifier<ProductState> {
  late final GetAllProductsUsecase _getAllProductsUsecase;
  late final GetAllProductsByBuyerIdUsecase _getAllProductsByBuyerIdUsecase;
  late final GetAllProductsBySellerIdUsecase _getAllProductsBySellerIdUsecase;
  late final GetProductByIdUsecase _getProductByIdUsecase;

  @override
  ProductState build() {
    _getAllProductsUsecase = ref.read(getAllProductsUsecaseProvider);
    _getAllProductsByBuyerIdUsecase = ref.read(
      getAllProductsByBuyerIdUsecaseProvider,
    );
    _getAllProductsBySellerIdUsecase = ref.read(
      getAllProductsBySellerIdUsecaseProvider,
    );
    _getProductByIdUsecase = ref.read(getProductByIdUsecaseProvider);
    return const ProductState();
  }

  Future<void> getAllProducts() async {
    state = state.copyWith(productStatus: ProductStatus.loading);
    final result = await _getAllProductsUsecase();

    result.fold(
      (failure) => state = state.copyWith(
        productStatus: ProductStatus.error,
        errorMessage: failure.message,
      ),
      (products) => state = state.copyWith(
        productStatus: ProductStatus.loaded,
        products: products,
      ),
    );
  }

  Future<void> getAllProductsByBuyerId(String buyerId) async {
    state = state.copyWith(productStatus: ProductStatus.loading);
    final result = await _getAllProductsByBuyerIdUsecase(
      GetAllProductsByBuyerIdUsecaseParams(buyerId: buyerId),
    );

    result.fold(
      (failure) => state = state.copyWith(
        productStatus: ProductStatus.error,
        errorMessage: failure.message,
      ),
      (products) => state = state.copyWith(
        productStatus: ProductStatus.loaded,
        products: products,
      ),
    );
  }

  Future<void> getAllProductsBySellerId(String sellerId) async {
    state = state.copyWith(productStatus: ProductStatus.loading);
    final result = await _getAllProductsBySellerIdUsecase(
      GetAllProductsBySellerIdUsecaseParams(sellerId: sellerId),
    );

    result.fold(
      (failure) => state = state.copyWith(
        productStatus: ProductStatus.error,
        errorMessage: failure.message,
      ),
      (products) => state = state.copyWith(
        productStatus: ProductStatus.loaded,
        products: products,
      ),
    );
  }

  Future<void> getProductById(String productId) async {
    state = state.copyWith(productStatus: ProductStatus.loading);

    final result = await _getProductByIdUsecase(
      GetProductByIdUsecaseParams(productId: productId),
    );

    result.fold(
      (failure) => state = state.copyWith(
        productStatus: ProductStatus.error,
        errorMessage: failure.message,
      ),
      (product) => state = state.copyWith(
        productStatus: ProductStatus.loaded,
        selectedProduct: product,
      ),
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void clearProductList() {
    state = state.copyWith(products: []);
  }

  void clearProductStatus() {
    state = state.copyWith(productStatus: ProductStatus.initial);
  }

  void clearSelectedProduct() {
    state = state.copyWith(selectedProduct: null);
  }

  // void clearProductImageUrlList() {
  //   state = state.copyWith(uploadedProductImageUrls: []);
  // }
}
