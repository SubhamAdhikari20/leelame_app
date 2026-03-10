// lib/features/order/domain/usecases/create_order_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/core/usecases/app_usecase.dart';
import 'package:leelame/features/order/data/repositories/order_repository.dart';
import 'package:leelame/features/order/domain/entities/order_entity.dart';
import 'package:leelame/features/order/domain/repositories/order_repository.dart';

class CreateOrderUsecaseParams extends Equatable {
  final String? orderId;
  final String productId;
  final String buyerId;
  final String sellerId;
  final DateTime delivaryDate;
  final String delivaryAddress;
  final double totalPrice;
  final OrderStatus status;
  final String? paymentReference;

  const CreateOrderUsecaseParams({
    this.orderId,
    required this.productId,
    required this.buyerId,
    required this.sellerId,
    required this.delivaryDate,
    required this.delivaryAddress,
    required this.totalPrice,
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

final createOrderUsecaseProvider = Provider<CreateOrderUsecase>((ref) {
  return CreateOrderUsecase(orderRepository: ref.read(orderRepositoryProvider));
});

class CreateOrderUsecase
    implements UsecaseWithParams<OrderEntity, CreateOrderUsecaseParams> {
  final IOrderRepository _orderRepository;

  CreateOrderUsecase({required IOrderRepository orderRepository})
    : _orderRepository = orderRepository;

  @override
  Future<Either<Failures, OrderEntity>> call(CreateOrderUsecaseParams params) {
    final orderEntity = OrderEntity(
      orderId: params.orderId,
      productId: params.productId,
      buyerId: params.buyerId,
      sellerId: params.sellerId,
      delivaryDate: params.delivaryDate,
      delivaryAddress: params.delivaryAddress,
      totalPrice: params.totalPrice,
      status: params.status,
      paymentReference: params.paymentReference,
    );

    return _orderRepository.createOrder(orderEntity);
  }
}
