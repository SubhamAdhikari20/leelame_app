// lib/features/invoice/domain/usecases/create_invoice_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/core/usecases/app_usecase.dart';
import 'package:leelame/features/invoice/data/repositories/invoice_repository.dart';
import 'package:leelame/features/invoice/domain/entities/invoice_entity.dart';
import 'package:leelame/features/invoice/domain/repositories/invoice_repository.dart';
import 'package:leelame/features/payment/domain/entities/payment_entity.dart';

class CreateInvoiceUsecaseParams extends Equatable {
  final String? invoiceId;
  final String productId;
  final String buyerId;
  final String sellerId;
  final String orderId;
  final String paymentId;
  final String transactionId;
  final String buyerName;
  final String? buyerContact;
  final String sellerName;
  final String sellerContact;
  final String productName;
  final double price;
  final double serviceCharge;
  final double totalPrice;
  final PaymentMethod paymentMethod;

  const CreateInvoiceUsecaseParams({
    this.invoiceId,
    required this.productId,
    required this.buyerId,
    required this.sellerId,
    required this.orderId,
    required this.paymentId,
    required this.transactionId,
    required this.buyerName,
    required this.buyerContact,
    required this.sellerName,
    required this.sellerContact,
    required this.productName,
    required this.price,
    required this.serviceCharge,
    required this.totalPrice,
    required this.paymentMethod,
  });

  @override
  List<Object?> get props => [
    invoiceId,
    productId,
    buyerId,
    sellerId,
    orderId,
    paymentId,
    transactionId,
    buyerName,
    buyerContact,
    sellerName,
    sellerContact,
    productName,
    price,
    serviceCharge,
    totalPrice,
    paymentMethod,
  ];
}

final createInvoiceUsecaseProvider = Provider<CreateInvoiceUsecase>((ref) {
  return CreateInvoiceUsecase(
    invoiceRepository: ref.read(invoiceRepositoryProvider),
  );
});

class CreateInvoiceUsecase
    implements UsecaseWithParams<InvoiceEntity, CreateInvoiceUsecaseParams> {
  final IInvoiceRepository _invoiceRepository;

  CreateInvoiceUsecase({required IInvoiceRepository invoiceRepository})
    : _invoiceRepository = invoiceRepository;

  @override
  Future<Either<Failures, InvoiceEntity>> call(
    CreateInvoiceUsecaseParams params,
  ) {
    final invoiceEntity = InvoiceEntity(
      invoiceId: params.invoiceId,
      productId: params.productId,
      buyerId: params.buyerId,
      sellerId: params.sellerId,
      orderId: params.orderId,
      paymentId: params.paymentId,
      transactionId: params.transactionId,
      buyerName: params.buyerName,
      buyerContact: params.buyerContact,
      sellerName: params.sellerName,
      sellerContact: params.sellerContact,
      productName: params.productName,
      price: params.price,
      serviceCharge: params.serviceCharge,
      totalPrice: params.totalPrice,
      paymentMethod: params.paymentMethod,
    );

    return _invoiceRepository.createInvoice(invoiceEntity);
  }
}
