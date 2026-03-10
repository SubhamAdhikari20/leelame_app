// lib/features/payment/presentation/models/payment_ui_model.dart
import 'package:leelame/features/payment/domain/entities/payment_entity.dart';

class PaymentUiModel {
  final String? paymentId;
  final String orderId;
  final String transactionId;
  final double amount;
  final PaymentMethod method;
  final PaymentStatus status;
  final String? checkoutUrl;

  const PaymentUiModel({
    this.paymentId,
    required this.orderId,
    required this.transactionId,
    required this.method,
    required this.amount,
    required this.status,
    this.checkoutUrl,
  });

  PaymentEntity toEntity() {
    return PaymentEntity(
      paymentId: paymentId,
      orderId: orderId,
      transactionId: transactionId,
      amount: amount,
      method: method,
      status: status,
      checkoutUrl: checkoutUrl,
    );
  }

  factory PaymentUiModel.fromEntity(PaymentEntity entity) {
    return PaymentUiModel(
      paymentId: entity.paymentId,
      orderId: entity.orderId,
      transactionId: entity.transactionId,
      amount: entity.amount,
      method: entity.method,
      status: entity.status,
      checkoutUrl: entity.checkoutUrl,
    );
  }

  PaymentUiModel copyWith({
    String? paymentId,
    String? orderId,
    String? transactionId,
    double? amount,
    PaymentMethod? method,
    PaymentStatus? status,
    String? checkoutUrl,
  }) {
    return PaymentUiModel(
      paymentId: paymentId ?? this.paymentId,
      orderId: orderId ?? this.orderId,
      transactionId: transactionId ?? this.transactionId,
      amount: amount ?? this.amount,
      method: method ?? this.method,
      status: status ?? this.status,
      checkoutUrl: checkoutUrl ?? this.checkoutUrl,
    );
  }
}
