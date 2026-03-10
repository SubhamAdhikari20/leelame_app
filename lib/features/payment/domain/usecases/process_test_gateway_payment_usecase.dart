import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/core/usecases/app_usecase.dart';
import 'package:leelame/features/payment/data/repositories/payment_repository.dart';
import 'package:leelame/features/payment/domain/entities/payment_entity.dart';
import 'package:leelame/features/payment/domain/repositories/payment_repository.dart';

class ProcessTestGatewayPaymentUsecaseParams extends Equatable {
  final String orderId;
  final PaymentMethod method;
  final double amount;

  const ProcessTestGatewayPaymentUsecaseParams({
    required this.orderId,
    required this.method,
    required this.amount,
  });

  @override
  List<Object?> get props => [orderId, method, amount];
}

final processTestGatewayPaymentUsecaseProvider = Provider<ProcessTestGatewayPaymentUsecase>((ref) {
  return ProcessTestGatewayPaymentUsecase(
    paymentRepository: ref.read(paymentRepositoryProvider),
  );
});

class ProcessTestGatewayPaymentUsecase
    implements UsecaseWithParams<PaymentEntity, ProcessTestGatewayPaymentUsecaseParams> {
  final IPaymentRepository _paymentRepository;

  ProcessTestGatewayPaymentUsecase({required IPaymentRepository paymentRepository})
    : _paymentRepository = paymentRepository;

  @override
  Future<Either<Failures, PaymentEntity>> call(ProcessTestGatewayPaymentUsecaseParams params) {
    return _paymentRepository.processTestGatewayPayment(
      orderId: params.orderId,
      method: params.method,
      amount: params.amount,
    );
  }
}
