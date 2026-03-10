// lib/features/invoice/presentation/view_models/invoice_view_model.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/features/invoice/domain/usecases/create_invoice_usecase.dart';
import 'package:leelame/features/invoice/presentation/states/invoice_state.dart';
import 'package:leelame/features/payment/domain/entities/payment_entity.dart';

final invoiceViewModelProvider =
    NotifierProvider<InvoiceViewModel, InvoiceState>(() => InvoiceViewModel());

class InvoiceViewModel extends Notifier<InvoiceState> {
  late final CreateInvoiceUsecase _createInvoiceUsecase;

  @override
  InvoiceState build() {
    _createInvoiceUsecase = ref.read(createInvoiceUsecaseProvider);
    return const InvoiceState();
  }

  Future<void> createInvoice({
    required String productId,
    required String buyerId,
    required String sellerId,
    required String orderId,
    required String paymentId,
    required String transactionId,
    required String buyerName,
    required String? buyerContact,
    required String sellerName,
    required String sellerContact,
    required String productName,
    required double price,
    required double serviceCharge,
    required double totalPrice,
    required PaymentMethod paymentMethod,
  }) async {
    state = state.copyWith(
      status: InvoiceViewStatus.loading,
      errorMessage: null,
    );

    final result = await _createInvoiceUsecase(
      CreateInvoiceUsecaseParams(
        productId: productId,
        buyerId: buyerId,
        sellerId: sellerId,
        orderId: orderId,
        paymentId: paymentId,
        transactionId: transactionId,
        buyerName: buyerName,
        buyerContact: buyerContact,
        sellerName: sellerName,
        sellerContact: sellerContact,
        productName: productName,
        price: price,
        serviceCharge: serviceCharge,
        totalPrice: totalPrice,
        paymentMethod: paymentMethod,
      ),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: InvoiceViewStatus.error,
          errorMessage: failure.message,
        );
      },
      (invoice) {
        state = state.copyWith(
          status: InvoiceViewStatus.generated,
          invoice: invoice,
        );
      },
    );
  }
}
