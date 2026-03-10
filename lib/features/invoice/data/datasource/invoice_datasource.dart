// lib/features/invoice/data/datasource/invoice_datasource.dart
import 'package:leelame/features/invoice/data/models/invoice_api_model.dart';

abstract interface class IInvoiceRemoteDatasource {
  Future<InvoiceApiModel?> createInvoice(InvoiceApiModel invoiceModel);
}
