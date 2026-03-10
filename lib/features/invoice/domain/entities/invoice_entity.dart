// lib/features/invoice/domain/entities/invoice_entity.dart
import 'package:equatable/equatable.dart';
import 'package:leelame/features/payment/domain/entities/payment_entity.dart';

class InvoiceEntity extends Equatable {
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

  const InvoiceEntity({
    this.invoiceId,
    required this.productId,
    required this.buyerId,
    required this.sellerId,
    required this.orderId,
    required this.paymentId,
    required this.transactionId,
    required this.buyerName,
    this.buyerContact,
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

  InvoiceEntity copyWith({
    String? invoiceId,
    String? productId,
    String? buyerId,
    String? sellerId,
    String? orderId,
    String? paymentId,
    String? transactionId,
    String? buyerName,
    String? buyerContact,
    String? sellerName,
    String? sellerContact,
    String? productName,
    double? price,
    double? serviceCharge,
    double? totalPrice,
    PaymentMethod? paymentMethod,
  }) {
    return InvoiceEntity(
      invoiceId: invoiceId ?? this.invoiceId,
      productId: productId ?? this.productId,
      buyerId: buyerId ?? this.buyerId,
      sellerId: sellerId ?? this.sellerId,
      orderId: orderId ?? this.orderId,
      paymentId: paymentId ?? this.paymentId,
      transactionId: transactionId ?? this.transactionId,
      buyerName: buyerName ?? this.buyerName,
      buyerContact: buyerContact ?? this.buyerContact,
      sellerName: sellerName ?? this.sellerName,
      sellerContact: sellerContact ?? this.sellerContact,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      serviceCharge: serviceCharge ?? this.serviceCharge,
      totalPrice: totalPrice ?? this.totalPrice,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }
}
