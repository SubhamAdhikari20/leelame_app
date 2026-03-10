import 'package:leelame/features/payment/data/models/payment_api_model.dart';
import 'package:leelame/features/payment/domain/entities/payment_entity.dart';

abstract interface class IPaymentRemoteDatasource {
  Future<PaymentApiModel?> initiatePayment(PaymentApiModel paymentModel);

  Future<PaymentApiModel> verifyPayment({
    required String orderId,
    required String transactionId,
    required PaymentMethod method,
  });

  Future<PaymentApiModel> processTestGatewayPayment({
    required String orderId,
    required PaymentMethod method,
    required double amount,
  });
}
