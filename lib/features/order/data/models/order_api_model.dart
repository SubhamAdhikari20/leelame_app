// lib/features/order/data/models/order_api_model.dart
import 'package:leelame/features/order/domain/entities/order_entity.dart';

class OrderApiModel {
  final String? id;
  final String productId;
  final String buyerId;
  final String sellerId;
  final DateTime delivaryDate;
  final String delivaryAddress;
  final double totalPrice;
  final OrderStatus status;
  final String? paymentReference;

  const OrderApiModel({
    this.id,
    required this.productId,
    required this.buyerId,
    required this.sellerId,
    required this.delivaryDate,
    required this.delivaryAddress,
    required this.totalPrice,
    required this.status,
    required this.paymentReference,
  });

  factory OrderApiModel.fromJson(Map<String, dynamic> json) {
    return OrderApiModel(
      id: json['_id'] as String? ?? json['id'] as String?,
      productId: json['productId'] as String,
      buyerId: json['buyerId'] as String,
      sellerId: json['sellerId'] as String,
      delivaryDate: 'delivaryDate' as DateTime,
      delivaryAddress: json['delivaryAddress'] as String,
      totalPrice: (json['totalPrice'] as num).toDouble(),
      status: OrderApiModel._orderStatusFromString(
        json['status'] as String? ?? 'pending',
      ),
      paymentReference: json['paymentReference'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'productId': productId,
      'buyerId': buyerId,
      'sellerId': sellerId,
      'delivaryDate': delivaryDate,
      'delivaryAddress': delivaryAddress,
      'totalPrice': totalPrice,
      'status': status.name,
      'paymentReference': paymentReference,
    };
  }

  OrderEntity toEntity() {
    return OrderEntity(
      orderId: id,
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

  factory OrderApiModel.fromEntity(OrderEntity entity) {
    return OrderApiModel(
      id: entity.orderId,
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

  OrderApiModel copyWith({
    String? id,
    String? productId,
    String? buyerId,
    String? sellerId,
    DateTime? delivaryDate,
    String? delivaryAddress,
    double? totalPrice,
    OrderStatus? status,
    String? paymentReference,
  }) {
    return OrderApiModel(
      id: id ?? this.id,
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

  static OrderStatus _orderStatusFromString(String value) {
    switch (value) {
      case 'delivered':
        return OrderStatus.delivered;
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }
}
