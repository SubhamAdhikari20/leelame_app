// lib/features/invoice/presentation/models/invoice_ui_model.dart
import 'package:leelame/features/invoice/domain/entities/invoice_entity.dart';
import 'package:leelame/features/payment/domain/entities/payment_entity.dart';

class InvoiceUiModel {
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

  const InvoiceUiModel({
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

  InvoiceEntity toEntity() {
    return InvoiceEntity(
      invoiceId: invoiceId,
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
    );
  }

  factory InvoiceUiModel.fromEntity(InvoiceEntity entity) {
    return InvoiceUiModel(
      invoiceId: entity.invoiceId,
      productId: entity.productId,
      buyerId: entity.buyerId,
      sellerId: entity.sellerId,
      orderId: entity.orderId,
      paymentId: entity.paymentId,
      transactionId: entity.transactionId,
      buyerName: entity.buyerName,
      buyerContact: entity.buyerContact,
      sellerName: entity.sellerName,
      sellerContact: entity.sellerContact,
      productName: entity.productName,
      price: entity.price,
      serviceCharge: entity.serviceCharge,
      totalPrice: entity.totalPrice,
      paymentMethod: entity.paymentMethod,
    );
  }

  InvoiceUiModel copyWith({
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
    return InvoiceUiModel(
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
