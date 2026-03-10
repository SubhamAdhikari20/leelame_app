// lib/features/payment/presentation/states/payment_state.dart
import 'package:equatable/equatable.dart';
import 'package:leelame/features/payment/domain/entities/payment_entity.dart';

enum PaymentViewStatus { initial, loading, success, failure }

class PaymentState extends Equatable {
  final PaymentViewStatus status;
  final PaymentEntity? payment;
  final String? errorMessage;

  const PaymentState({
    this.status = PaymentViewStatus.initial,
    this.payment,
    this.errorMessage,
  });

  PaymentState copyWith({
    PaymentViewStatus? status,
    PaymentEntity? payment,
    String? errorMessage,
  }) {
    return PaymentState(
      status: status ?? this.status,
      payment: payment ?? this.payment,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, payment, errorMessage];
}
