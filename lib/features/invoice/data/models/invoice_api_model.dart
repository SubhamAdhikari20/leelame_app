// lib/features/invoice/data/models/invoice_api_model.dart
import 'package:leelame/features/invoice/domain/entities/invoice_entity.dart';
import 'package:leelame/features/payment/domain/entities/payment_entity.dart';

class InvoiceApiModel {
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

  InvoiceApiModel({
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

  factory InvoiceApiModel.fromJson(Map<String, dynamic> json) {
    return InvoiceApiModel(
      invoiceId: json['_id'] as String?,
      productId: json['product_id'] as String,
      buyerId: json['buyer_id'] as String,
      sellerId: json['seller_id'] as String,
      orderId: json['order_id'] as String,
      paymentId: json['payment_id'] as String,
      transactionId: json['transaction_id'] as String,
      buyerName: json['buyer_name'] as String,
      buyerContact: json['buyer_contact'] as String?,
      sellerName: json['seller_name'] as String,
      sellerContact: json['seller_contact'] as String,
      productName: json['product_name'] as String,
      price: (json['price'] as num).toDouble(),
      serviceCharge: (json['service_charge'] as num).toDouble(),
      totalPrice: (json['total_price'] as num).toDouble(),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.label == json['payment_method'],
        orElse: () => PaymentMethod.khalti, // Default value
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': invoiceId,
      'product_id': productId,
      'buyer_id': buyerId,
      'seller_id': sellerId,
      'order_id': orderId,
      'payment_id': paymentId,
      'transaction_id': transactionId,
      'buyer_name': buyerName,
      'buyer_contact': buyerContact,
      'seller_name': sellerName,
      'seller_contact': sellerContact,
      'product_name': productName,
      'price': price,
      'service_charge': serviceCharge,
      'total_price': totalPrice,
      'payment_method': paymentMethod,
    };
  }

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

  factory InvoiceApiModel.fromEntity(InvoiceEntity entity) {
    return InvoiceApiModel(
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

  InvoiceApiModel copyWith({
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
    return InvoiceApiModel(
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
