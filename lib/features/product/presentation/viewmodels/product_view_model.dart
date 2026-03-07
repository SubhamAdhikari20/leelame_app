// lib/features/product/presentation/view_models/product_view_model.dart
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/features/product/domain/usecases/add_product_usecase.dart';
import 'package:leelame/features/product/domain/usecases/delete_product_usecase.dart';
import 'package:leelame/features/product/domain/usecases/get_all_products_by_buyer_id_usecase.dart';
import 'package:leelame/features/product/domain/usecases/get_all_products_by_seller_id_usecase.dart';
import 'package:leelame/features/product/domain/usecases/get_all_products_usecase.dart';
import 'package:leelame/features/product/domain/usecases/get_product_by_id_usecase.dart';
import 'package:leelame/features/product/domain/usecases/update_product_usecase.dart';
import 'package:leelame/features/product/presentation/states/product_state.dart';

final productViewModelProvider =
    NotifierProvider<ProductViewModel, ProductState>(() {
      return ProductViewModel();
    });

class ProductViewModel extends Notifier<ProductState> {
  late final AddProductUsecase _addProductUsecase;
  late final UpdateProductUsecase _updateProductUsecase;
  late final DeleteProductUsecase _deleteProductUsecase;
  late final GetAllProductsUsecase _getAllProductsUsecase;
  late final GetAllProductsByBuyerIdUsecase _getAllProductsByBuyerIdUsecase;
  late final GetAllProductsBySellerIdUsecase _getAllProductsBySellerIdUsecase;
  late final GetProductByIdUsecase _getProductByIdUsecase;

  @override
  ProductState build() {
    _addProductUsecase = ref.read(addProductUsecaseProvider);
    _updateProductUsecase = ref.read(updateProductUsecaseProvider);
    _deleteProductUsecase = ref.read(deleteProductUsecaseProvider);
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

  Future<void> addProduct({
    required String productName,
    String? description,
    String? sellerId,
    String? categoryId,
    String? conditionId,
    required double startPrice,
    required double bidIntervalPrice,
    required DateTime endDate,
    List<File>? productImages,
    String? imageSubFolder,
  }) async {
    state = state.copyWith(productStatus: ProductStatus.loading);
    final result = await _addProductUsecase(
      AddProductUsecaseParams(
        productName: productName,
        description: description,
        sellerId: sellerId,
        categoryId: categoryId,
        conditionId: conditionId,
        startPrice: startPrice,
        bidIntervalPrice: bidIntervalPrice,
        endDate: endDate,
        productImages: productImages,
        imageSubFolder: imageSubFolder,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        productStatus: ProductStatus.error,
        errorMessage: failure.message,
      ),
      (product) => state = state.copyWith(
        productStatus: ProductStatus.created,
        selectedProduct: product,
      ),
    );
  }

  Future<void> updateProduct({
    required String productId,
    String? productName,
    String? description,
    String? sellerId,
    String? categoryId,
    String? conditionId,
    double? startPrice,
    double? currentBidPrice,
    double? bidIntervalPrice,
    DateTime? endDate,
    List<File>? productImages,
    String? imageSubFolder,
  }) async {
    state = state.copyWith(productStatus: ProductStatus.loading);
    final result = await _updateProductUsecase(
      UpdateProductUsecaseParams(
        productId: productId,
        productName: productName,
        description: description,
        sellerId: sellerId,
        categoryId: categoryId,
        conditionId: conditionId,
        startPrice: startPrice,
        currentBidPrice: currentBidPrice,
        bidIntervalPrice: bidIntervalPrice,
        endDate: endDate,
        productImages: productImages,
        imageSubFolder: imageSubFolder,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        productStatus: ProductStatus.error,
        errorMessage: failure.message,
      ),
      (product) => state = state.copyWith(
        productStatus: ProductStatus.updated,
        selectedProduct: product,
      ),
    );
  }

  Future<void> deleteProduct({required String productId}) async {
    state = state.copyWith(productStatus: ProductStatus.loading);
    final result = await _deleteProductUsecase(
      DeleteProductUsecaseParams(productId: productId),
    );

    result.fold(
      (failure) => state = state.copyWith(
        productStatus: ProductStatus.error,
        errorMessage: failure.message,
      ),
      (result) => state = state.copyWith(
        productStatus: ProductStatus.deleted,
        selectedProduct: null,
      ),
    );
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
