// lib/features/payment/data/models/payment_api_model.dart
import 'package:leelame/features/payment/domain/entities/payment_entity.dart';

class PaymentApiModel {
  final String? id;
  final String orderId;
  final String transactionId;
  final double amount;
  final PaymentMethod method;
  final PaymentStatus status;
  final String? checkoutUrl;

  const PaymentApiModel({
    this.id,
    required this.orderId,
    required this.transactionId,
    required this.method,
    required this.amount,
    required this.status,
    this.checkoutUrl,
  });

  factory PaymentApiModel.fromJson(Map<String, dynamic> json) {
    return PaymentApiModel(
      id: json['_id'] as String? ?? json['id'] as String?,
      orderId: json['orderId'] as String,
      transactionId: json['transactionId'] as String,
      method: PaymentApiModel._gatewayFromString(
        json['method'] as String? ?? 'khalti',
      ),
      amount: (json['amount'] as num).toDouble(),
      status: PaymentApiModel._statusFromString(
        json['status'] as String? ?? 'pending',
      ),
      checkoutUrl: json['checkoutUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'orderId': orderId,
      'transactionId': transactionId,
      'method': method.name,
      'amount': amount,
      'status': status.name,
      'checkoutUrl': checkoutUrl,
    };
  }

  PaymentEntity toEntity() {
    return PaymentEntity(
      paymentId: id,
      orderId: orderId,
      transactionId: transactionId,
      amount: amount,
      method: method,
      status: status,
      checkoutUrl: checkoutUrl,
    );
  }

  factory PaymentApiModel.fromEntity(PaymentEntity entity) {
    return PaymentApiModel(
      id: entity.paymentId,
      orderId: entity.orderId,
      transactionId: entity.transactionId,
      amount: entity.amount,
      method: entity.method,
      status: entity.status,
      checkoutUrl: entity.checkoutUrl,
    );
  }

  static PaymentMethod _gatewayFromString(String value) {
    if (value.toLowerCase() == 'esewa') {
      return PaymentMethod.esewa;
    }
    return PaymentMethod.khalti;
  }

  static PaymentStatus _statusFromString(String value) {
    switch (value) {
      case 'success':
        return PaymentStatus.success;
      case 'failed':
        return PaymentStatus.failed;
      default:
        return PaymentStatus.pending;
    }
  }
}
