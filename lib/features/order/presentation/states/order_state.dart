// lib/features/order/presentation/states/order_state.dart
import 'package:equatable/equatable.dart';
import 'package:leelame/features/order/domain/entities/order_entity.dart';

enum OrderViewStatus { initial, loading, loaded, created, updated, error }

class OrderState extends Equatable {
  final OrderViewStatus status;
  final OrderEntity? order;
  final String? errorMessage;

  const OrderState({
    this.status = OrderViewStatus.initial,
    this.order,
    this.errorMessage,
  });

  OrderState copyWith({
    OrderViewStatus? status,
    OrderEntity? order,
    String? errorMessage,
  }) {
    return OrderState(
      status: status ?? this.status,
      order: order ?? this.order,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, order, errorMessage];
}
