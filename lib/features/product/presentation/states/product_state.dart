// lib/features/product/presentation/states/product_state.dart
import 'package:equatable/equatable.dart';
import 'package:leelame/features/product/domain/entities/product_entity.dart';

enum ProductStatus {
  initial,
  loading,
  loaded,
  error,
  created,
  updated,
  deleted,
  // imagesLoaded,
}

class ProductState extends Equatable {
  final ProductStatus productStatus;
  final List<ProductEntity> products;
  final ProductEntity? selectedProduct;
  final String? errorMessage;
  // final List<String> uploadedProductImageUrls;

  const ProductState({
    this.productStatus = ProductStatus.initial,
    this.products = const [],
    this.selectedProduct,
    this.errorMessage,
    // this.uploadedProductImageUrls = const [],
  });

  ProductState copyWith({
    ProductStatus? productStatus,
    List<ProductEntity>? products,
    ProductEntity? selectedProduct,
    String? errorMessage,
    // List<String>? uploadedProductImageUrls,
  }) {
    return ProductState(
      productStatus: productStatus ?? this.productStatus,
      products: products ?? this.products,
      selectedProduct: selectedProduct ?? this.selectedProduct,
      errorMessage: errorMessage ?? this.errorMessage,
      // uploadedProductImageUrls:
      //     uploadedProductImageUrls ?? this.uploadedProductImageUrls,
    );
  }

  @override
  List<Object?> get props => [
    productStatus,
    products,
    selectedProduct,
    errorMessage,
    // uploadedProductImageUrls,
  ];
}
