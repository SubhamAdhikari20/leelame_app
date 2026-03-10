// lib/features/order/domain/usecases/update_order_status_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/core/usecases/app_usecase.dart';
import 'package:leelame/features/order/data/repositories/order_repository.dart';
import 'package:leelame/features/order/domain/entities/order_entity.dart';
import 'package:leelame/features/order/domain/repositories/order_repository.dart';

class UpdateOrderDetailsUsecaseParams extends Equatable {
  final String orderId;
  final String? productId;
  final String? buyerId;
  final String? sellerId;
  final DateTime? delivaryDate;
  final String? delivaryAddress;
  final double? totalPrice;
  final OrderStatus? status;
  final String? paymentReference;

  const UpdateOrderDetailsUsecaseParams({
    required this.orderId,
    this.productId,
    this.buyerId,
    this.sellerId,
    this.delivaryDate,
    this.delivaryAddress,
    this.totalPrice,
    this.status = OrderStatus.pending,
    this.paymentReference,
  });

  @override
  List<Object?> get props => [
    orderId,
    productId,
    buyerId,
    sellerId,
    delivaryDate,
    delivaryAddress,
    totalPrice,
    status,
    paymentReference,
  ];
}

final updateOrderDetailsUsecaseProvider = Provider<UpdateOrderDetailsUsecase>((
  ref,
) {
  return UpdateOrderDetailsUsecase(
    orderRepository: ref.read(orderRepositoryProvider),
  );
});

class UpdateOrderDetailsUsecase
    implements UsecaseWithParams<OrderEntity, UpdateOrderDetailsUsecaseParams> {
  final IOrderRepository _orderRepository;

  UpdateOrderDetailsUsecase({required IOrderRepository orderRepository})
    : _orderRepository = orderRepository;

  @override
  Future<Either<Failures, OrderEntity>> call(
    UpdateOrderDetailsUsecaseParams params,
  ) async {
    final orderResult = await _orderRepository.getOrderById(params.orderId);

    return orderResult.fold(
      (failure) {
        return Left(failure);
      },
      (existingOrder) async {
        final updatedOrder = existingOrder.copyWith(
          productId: params.productId,
          buyerId: params.buyerId,
          sellerId: params.sellerId,
          delivaryDate: params.delivaryDate,
          delivaryAddress: params.delivaryAddress,
          totalPrice: params.totalPrice,
          status: params.status,
          paymentReference: params.paymentReference,
        );

        return await _orderRepository.updateOrderDetails(updatedOrder);
      },
    );
  }
}
