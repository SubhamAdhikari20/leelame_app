// lib/features/payment/domain/usecases/initiate_payment_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/core/usecases/app_usecase.dart';
import 'package:leelame/features/payment/data/repositories/payment_repository.dart';
import 'package:leelame/features/payment/domain/entities/payment_entity.dart';
import 'package:leelame/features/payment/domain/repositories/payment_repository.dart';

class InitiatePaymentUsecaseParams extends Equatable {
  final String orderId;
  final String transactionId;
  final double amount;
  final PaymentMethod method;
  final PaymentStatus status;
  final String? checkoutUrl;

  const InitiatePaymentUsecaseParams({
    required this.orderId,
    required this.transactionId,
    required this.amount,
    required this.method,
    this.status = PaymentStatus.pending,
    this.checkoutUrl,
  });

  @override
  List<Object?> get props => [
    orderId,
    transactionId,
    amount,
    method,
    status,
    checkoutUrl,
  ];
}

final initiatePaymentUsecaseProvider = Provider<InitiatePaymentUsecase>((ref) {
  return InitiatePaymentUsecase(
    paymentRepository: ref.read(paymentRepositoryProvider),
  );
});

class InitiatePaymentUsecase
    implements UsecaseWithParams<PaymentEntity, InitiatePaymentUsecaseParams> {
  final IPaymentRepository _paymentRepository;

  InitiatePaymentUsecase({required IPaymentRepository paymentRepository})
    : _paymentRepository = paymentRepository;

  @override
  Future<Either<Failures, PaymentEntity>> call(
    InitiatePaymentUsecaseParams params,
  ) async {
    final paymentEntity = PaymentEntity(
      orderId: params.orderId,
      transactionId: params.transactionId,
      amount: params.amount,
      method: params.method,
      status: params.status,
      checkoutUrl: params.checkoutUrl,
    );

    return await _paymentRepository.initiatePayment(paymentEntity);
  }
}
