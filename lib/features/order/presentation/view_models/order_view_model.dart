// lib/features/order/presentation/view_models/order_view_model.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/features/order/domain/entities/order_entity.dart';
import 'package:leelame/features/order/domain/usecases/create_order_usecase.dart';
import 'package:leelame/features/order/domain/usecases/update_order_details_usecase.dart';
import 'package:leelame/features/order/domain/usecases/update_order_status_usecase.dart';
import 'package:leelame/features/order/presentation/states/order_state.dart';

final orderViewModelProvider = NotifierProvider<OrderViewModel, OrderState>(() {
  return OrderViewModel();
});

class OrderViewModel extends Notifier<OrderState> {
  late final CreateOrderUsecase _createOrderUsecase;
  late final UpdateOrderDetailsUsecase _updateOrderDetailsUsecase;
  late final UpdateOrderStatusUsecase _updateOrderStatusUsecase;

  @override
  OrderState build() {
    _createOrderUsecase = ref.read(createOrderUsecaseProvider);
    _updateOrderDetailsUsecase = ref.read(updateOrderDetailsUsecaseProvider);
    _updateOrderStatusUsecase = ref.read(updateOrderStatusUsecaseProvider);
    return const OrderState();
  }

  Future<void> createOrder({
    required String productId,
    required String buyerId,
    required String sellerId,
    required DateTime delivaryDate,
    required String delivaryAddress,
    required double totalPrice,
    required OrderStatus status,
     String? paymentReference,
  }) async {
    state = state.copyWith(status: OrderViewStatus.loading, errorMessage: null);

    final result = await _createOrderUsecase(
      CreateOrderUsecaseParams(
        productId: productId,
        buyerId: buyerId,
        sellerId: sellerId,
        delivaryDate: delivaryDate,
        delivaryAddress: delivaryAddress,
        totalPrice: totalPrice,
        status: status,
        paymentReference: paymentReference,
      ),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: OrderViewStatus.error,
          errorMessage: failure.message,
        );
      },
      (order) {
        state = state.copyWith(status: OrderViewStatus.created, order: order);
      },
    );
  }

  Future<OrderEntity?> updateOrderDetails({
    required String orderId,
    String? productId,
    String? buyerId,
    String? sellerId,
    DateTime? delivaryDate,
    String? delivaryAddress,
    double? totalPrice,
    OrderStatus? status,
    String? paymentReference,
  }) async {
    state = state.copyWith(status: OrderViewStatus.loading, errorMessage: null);

    final result = await _updateOrderDetailsUsecase(
      UpdateOrderDetailsUsecaseParams(
        orderId: orderId,
        productId: productId,
        buyerId: buyerId,
        sellerId: sellerId,
        delivaryDate: delivaryDate,
        delivaryAddress: delivaryAddress,
        totalPrice: totalPrice,
        status: status,
        paymentReference: paymentReference,
      ),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: OrderViewStatus.error,
          errorMessage: failure.message,
        );
        return null;
      },
      (order) {
        state = state.copyWith(status: OrderViewStatus.updated, order: order);
        return order;
      },
    );
  }

  Future<OrderEntity?> updateOrderStatus({
    required String orderId,
    required OrderStatus status,
  }) async {
    state = state.copyWith(status: OrderViewStatus.loading, errorMessage: null);

    final result = await _updateOrderStatusUsecase(
      UpdateOrderStatusUsecaseParams(orderId: orderId, status: status),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: OrderViewStatus.error,
          errorMessage: failure.message,
        );
        return null;
      },
      (order) {
        state = state.copyWith(status: OrderViewStatus.updated, order: order);
        return order;
      },
    );
  }

  void clearStatus() {
    state = state.copyWith(status: OrderViewStatus.initial, errorMessage: null);
  }

  void clearOrder() {
    state = state.copyWith(order: null);
  }
}
