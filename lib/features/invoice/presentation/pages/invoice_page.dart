import 'package:flutter/material.dart';
import 'package:leelame/features/invoice/presentation/models/invoice_ui_model.dart';

class InvoicePage extends StatelessWidget {
  const InvoicePage({super.key, required this.invoice});

  final InvoiceUiModel invoice;

  String _amount(double value) => 'Rs. ${value.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Invoice')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payment Successful',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                _line('Invoice Id', invoice.invoiceId ?? '-'),
                _line('Order Id', invoice.orderId),
                _line('Payment Id', invoice.paymentId),
                _line('Transaction Id', invoice.transactionId),
                _line('Buyer', invoice.buyerName),
                _line('Seller', invoice.sellerName),
                _line('Product', invoice.productName),
                _line('Method', invoice.paymentMethod.name.toUpperCase()),
                const Divider(height: 24),
                _line('Price', _amount(invoice.price)),
                _line('Service Charge', _amount(invoice.serviceCharge)),
                _line('Total', _amount(invoice.totalPrice), isBold: true),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _line(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
