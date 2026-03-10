// lib/features/payment/domain/entities/payment_entity.dart
import 'package:equatable/equatable.dart';

enum PaymentMethod { khalti, esewa }

enum PaymentStatus { pending, success, failed }

extension PaymentMethodX on PaymentMethod {
  String get label {
    switch (this) {
      case PaymentMethod.khalti:
        return 'Khalti';
      case PaymentMethod.esewa:
        return 'eSewa';
    }
  }
}

class PaymentEntity extends Equatable {
  final String? paymentId;
  final String orderId;
  final String transactionId;
  final double amount;
  final PaymentMethod method;
  final PaymentStatus status;
  final String? checkoutUrl;

  const PaymentEntity({
    this.paymentId,
    required this.orderId,
    required this.transactionId,
    required this.amount,
    required this.method,
    this.status = PaymentStatus.pending,
    this.checkoutUrl,
  });

  @override
  List<Object?> get props => [
    paymentId,
    orderId,
    transactionId,
    amount,
    method,
    status,
    checkoutUrl,
  ];

  PaymentEntity copyWith({
    String? paymentId,
    String? orderId,
    String? transactionId,
    double? amount,
    PaymentMethod? method,
    PaymentStatus? status,
    String? checkoutUrl,
  }) {
    return PaymentEntity(
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
