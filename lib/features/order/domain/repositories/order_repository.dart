// src/features/order/domain/repositories/order_repository.dart
import 'package:dartz/dartz.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/features/order/domain/entities/order_entity.dart';

abstract interface class IOrderRepository {
  Future<Either<Failures, OrderEntity>> createOrder(OrderEntity order);
  Future<Either<Failures, OrderEntity>> updateOrderDetails(
    OrderEntity orderEntity,
  );
  Future<Either<Failures, OrderEntity>> updateOrderStatus(
    String orderId,
    OrderStatus orderStatus,
  );
  Future<Either<Failures, OrderEntity>> getOrderById(String orderId);
}
