// lib/features/payment/presentation/view_models/payment_view_model.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/features/payment/domain/entities/payment_entity.dart';
import 'package:leelame/features/payment/domain/usecases/initiate_payment_usecase.dart';
import 'package:leelame/features/payment/domain/usecases/process_test_gateway_payment_usecase.dart';
import 'package:leelame/features/payment/presentation/states/payment_state.dart';

final paymentViewModelProvider =
    NotifierProvider<PaymentViewModel, PaymentState>(() {
      return PaymentViewModel();
    });

class PaymentViewModel extends Notifier<PaymentState> {
  late final InitiatePaymentUsecase _initiatePaymentUsecase;
  late final ProcessTestGatewayPaymentUsecase _processTestGatewayPaymentUsecase;

  @override
  PaymentState build() {
    _initiatePaymentUsecase = ref.read(initiatePaymentUsecaseProvider);
    _processTestGatewayPaymentUsecase = ref.read(
      processTestGatewayPaymentUsecaseProvider,
    );
    return const PaymentState();
  }

  Future<void> initiatePayment({
    required String orderId,
    required String transactionId,
    required double amount,
    required PaymentMethod method,
    PaymentStatus status = PaymentStatus.pending,
    String? checkoutUrl,
  }) async {
    state = state.copyWith(
      status: PaymentViewStatus.loading,
      errorMessage: null,
    );

    final result = await _initiatePaymentUsecase(
      InitiatePaymentUsecaseParams(
        orderId: orderId,
        transactionId: transactionId,
        amount: amount,
        method: method,
        status: status,
        checkoutUrl: checkoutUrl,
      ),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: PaymentViewStatus.failure,
          errorMessage: failure.message,
        );
      },
      (payment) {
        state = state.copyWith(
          status: PaymentViewStatus.success,
          payment: payment,
        );
      },
    );
  }

  Future<PaymentEntity?> processTestGatewayPayment({
    required String orderId,
    required PaymentMethod method,
    required double amount,
  }) async {
    state = state.copyWith(
      status: PaymentViewStatus.loading,
      errorMessage: null,
    );

    final result = await _processTestGatewayPaymentUsecase(
      ProcessTestGatewayPaymentUsecaseParams(
        orderId: orderId,
        method: method,
        amount: amount,
      ),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: PaymentViewStatus.failure,
          errorMessage: failure.message,
        );
        return null;
      },
      (payment) {
        state = state.copyWith(
          status: PaymentViewStatus.success,
          payment: payment,
        );
        return payment;
      },
    );
  }

  void clearStatus() {
    state = state.copyWith(
      status: PaymentViewStatus.initial,
      errorMessage: null,
    );
  }
}
