// lib/core/constants/esewa.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:esewa_flutter_sdk/esewa_config.dart';
import 'package:esewa_flutter_sdk/esewa_flutter_sdk.dart';
import 'package:esewa_flutter_sdk/esewa_payment.dart';
import 'package:esewa_flutter_sdk/esewa_payment_success_result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/api/api_client.dart';
import 'package:leelame/core/constants/esewa.dart';
import 'package:leelame/features/payment/domain/entities/payment_entity.dart';
import 'package:leelame/features/payment/presentation/models/payment_ui_model.dart';
import 'package:leelame/features/product/data/models/product_api_model.dart';

final esewaProvider = Provider<Esewa>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return Esewa(apiClient: apiClient);
});

class Esewa {
  final ApiClient _apiClient;

  Esewa({required ApiClient apiClient}) : _apiClient = apiClient;

  PaymentStatus pay({
    required ProductApiModel product,
    required PaymentUiModel payment,
  }) {
    try {
      EsewaFlutterSdk.initPayment(
        esewaConfig: EsewaConfig(
          environment: Environment.test,
          clientId: esewaClientId,
          secretId: esewaSecretKey,
        ),
        esewaPayment: EsewaPayment(
          productId: product.id!,
          productName: product.productName,
          productPrice: payment.amount.toString(),
          callbackUrl: '',
        ),
        onPaymentSuccess: (EsewaPaymentSuccessResult result) {
          verify(result);
          return PaymentStatus.success;
        },
        onPaymentFailure: () {
          return PaymentStatus.failed;
        },
        onPaymentCancellation: () {
          return PaymentStatus.failed;
        },
      );
      return PaymentStatus.success;
    } catch (e) {
      return PaymentStatus.failed;
    }
  }

  dynamic verify(EsewaPaymentSuccessResult result) async {
    try {
      String basic =
          'Basic ${base64.encode(utf8.encode('JB0BBQ4aD0UqIThFJwAKBgAXEUkEGQUBBAwdOgABHD4DChwUAB0R:BhwIWQQADhIYSxILExMcAgFXFhcOBwAKBgAXEQ=='))}';
      Response response = await _apiClient.get(
        'https://esewa.com.np/mobile/transaction',
        queryParameters: {'txnRefId': result.refId},
        options: Options(headers: {'Authorization': basic}),
      );
      return response.data;
    } catch (e) {
      return null;
    }
  }
}
