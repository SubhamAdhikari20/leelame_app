// lib/features/invoice/domain/repositories/invoice_repository.dart
import 'package:dartz/dartz.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/features/invoice/domain/entities/invoice_entity.dart';

abstract interface class IInvoiceRepository {
  Future<Either<Failures, InvoiceEntity>> createInvoice(InvoiceEntity invoice);
}
