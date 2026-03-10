// lib/features/order/domain/entities/order_entity.dart
import 'package:equatable/equatable.dart';

enum OrderStatus { pending, confirmed, shipped, delivered, cancelled, failed }

class OrderEntity extends Equatable {
  final String? orderId;
  final String productId;
  final String buyerId;
  final String sellerId;
  final DateTime delivaryDate;
  final String delivaryAddress;
  final double totalPrice;
  final OrderStatus status;
  final String? paymentReference;

  const OrderEntity({
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

  OrderEntity copyWith({
    String? orderId,
    String? productId,
    String? buyerId,
    String? sellerId,
    DateTime? delivaryDate,
    String? delivaryAddress,
    double? totalPrice,
    OrderStatus? status,
    String? paymentReference,
  }) {
    return OrderEntity(
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      buyerId: buyerId ?? this.buyerId,
      sellerId: sellerId ?? this.sellerId,
      delivaryDate: delivaryDate ?? this.delivaryDate,
      delivaryAddress: delivaryAddress ?? this.delivaryAddress,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      paymentReference: paymentReference ?? this.paymentReference,
    );
  }
}
