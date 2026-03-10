import 'package:dartz/dartz.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/features/payment/domain/entities/payment_entity.dart';

abstract interface class IPaymentRepository {
  Future<Either<Failures, PaymentEntity>> initiatePayment(
    PaymentEntity payment,
  );

  Future<Either<Failures, PaymentEntity>> verifyPayment({
    required String orderId,
    required String transactionId,
    required PaymentMethod method,
  });

  Future<Either<Failures, PaymentEntity>> processTestGatewayPayment({
    required String orderId,
    required PaymentMethod method,
    required double amount,
  });
}
