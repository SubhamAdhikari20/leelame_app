// lib/features/order/presentation/models/order_ui_model.dart
import 'package:leelame/features/order/domain/entities/order_entity.dart';

class OrderUiModel {
  final String? orderId;
  final String productId;
  final String buyerId;
  final String sellerId;
  final DateTime delivaryDate;
  final String delivaryAddress;
  final double totalPrice;
  final OrderStatus status;
  final String? paymentReference;

  const OrderUiModel({
    this.orderId,
    required this.productId,
    required this.buyerId,
    required this.sellerId,
    required this.delivaryDate,
    required this.delivaryAddress,
    required this.totalPrice,
    required this.status,
    required this.paymentReference,
  });

  OrderEntity toEntity() {
    return OrderEntity(
      orderId: orderId,
      productId: productId,
      buyerId: buyerId,
      sellerId: sellerId,
      delivaryDate: delivaryDate,
      delivaryAddress: delivaryAddress,
      totalPrice: totalPrice,
      status: status,
      paymentReference: paymentReference,
    );
  }

  factory OrderUiModel.fromEntity(OrderEntity entity) {
    return OrderUiModel(
      orderId: entity.orderId,
      productId: entity.productId,
      buyerId: entity.buyerId,
      sellerId: entity.sellerId,
      delivaryDate: entity.delivaryDate,
      delivaryAddress: entity.delivaryAddress,
      totalPrice: entity.totalPrice,
      status: entity.status,
      paymentReference: entity.paymentReference,
    );
  }

  OrderUiModel copyWith({
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
    return OrderUiModel(
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
