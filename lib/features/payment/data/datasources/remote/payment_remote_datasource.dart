import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/api/api_client.dart';
import 'package:leelame/core/api/api_endpoints.dart';
import 'package:leelame/core/services/storage/token_service.dart';
import 'package:leelame/features/payment/data/datasources/payment_datasource.dart';
import 'package:leelame/features/payment/data/models/payment_api_model.dart';
import 'package:leelame/features/payment/domain/entities/payment_entity.dart';

final paymentRemoteDatasourceProvider = Provider<IPaymentRemoteDatasource>((
  ref,
) {
  return PaymentRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

class PaymentRemoteDatasource implements IPaymentRemoteDatasource {
  final ApiClient _apiClient;
  final TokenService _tokenService;

  PaymentRemoteDatasource({
    required ApiClient apiClient,
    required TokenService tokenService,
  }) : _apiClient = apiClient,
       _tokenService = tokenService;

  @override
  Future<PaymentApiModel?> initiatePayment(PaymentApiModel paymentModel) async {
    final token = _tokenService.getToken();
    final response = await _apiClient.post(
      ApiEndpoints.paymentCheckout,
      data: paymentModel.toJson(),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    final success = response.data['success'] as bool? ?? false;
    final data = response.data['data'] as Map<String, dynamic>?;

    if (!success || data == null) {
      return null;
    }

    return PaymentApiModel.fromJson(data);
  }

  @override
  Future<PaymentApiModel> processTestGatewayPayment({
    required String orderId,
    required PaymentMethod method,
    required double amount,
  }) async {
    // TODO: implement processTestGatewayPayment
    throw UnimplementedError();
  }

  @override
  Future<PaymentApiModel> verifyPayment({
    required String orderId,
    required String transactionId,
    required PaymentMethod method,
  }) async {
    // TODO: implement verifyPayment
    throw UnimplementedError();
  }
}
