// lib/features/order/domain/usecases/update_order_status_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/core/usecases/app_usecase.dart';
import 'package:leelame/features/order/data/repositories/order_repository.dart';
import 'package:leelame/features/order/domain/entities/order_entity.dart';
import 'package:leelame/features/order/domain/repositories/order_repository.dart';

class UpdateOrderStatusUsecaseParams extends Equatable {
  final String orderId;
  final OrderStatus status;

  const UpdateOrderStatusUsecaseParams({
    required this.orderId,

    this.status = OrderStatus.pending,
  });

  @override
  List<Object?> get props => [orderId, status];
}

final updateOrderStatusUsecaseProvider = Provider<UpdateOrderStatusUsecase>((
  ref,
) {
  return UpdateOrderStatusUsecase(
    orderRepository: ref.read(orderRepositoryProvider),
  );
});

class UpdateOrderStatusUsecase
    implements UsecaseWithParams<OrderEntity, UpdateOrderStatusUsecaseParams> {
  final IOrderRepository _orderRepository;

  UpdateOrderStatusUsecase({required IOrderRepository orderRepository})
    : _orderRepository = orderRepository;

  @override
  Future<Either<Failures, OrderEntity>> call(
    UpdateOrderStatusUsecaseParams params,
  ) {
    return _orderRepository.updateOrderStatus(params.orderId, params.status);
  }
}
