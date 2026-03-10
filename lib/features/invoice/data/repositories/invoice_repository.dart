// lib/features/invoice/data/repositories/invoice_repository.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/core/services/connectivity/network_info.dart';
import 'package:leelame/features/invoice/data/datasource/invoice_datasource.dart';
import 'package:leelame/features/invoice/data/datasource/remote/invoice_remote_datasource.dart';
import 'package:leelame/features/invoice/data/models/invoice_api_model.dart';
import 'package:leelame/features/invoice/domain/entities/invoice_entity.dart';
import 'package:leelame/features/invoice/domain/repositories/invoice_repository.dart';

final invoiceRepositoryProvider = Provider<IInvoiceRepository>((ref) {
  return InvoiceRepository(
    invoiceRemoteDatasource: ref.read(invoiceRemoteDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class InvoiceRepository implements IInvoiceRepository {
  final IInvoiceRemoteDatasource _invoiceRemoteDatasource;
  final INetworkInfo _networkInfo;

  InvoiceRepository({
    required IInvoiceRemoteDatasource invoiceRemoteDatasource,
    required INetworkInfo networkInfo,
  }) : _invoiceRemoteDatasource = invoiceRemoteDatasource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failures, InvoiceEntity>> createInvoice(
    InvoiceEntity invoice,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'Internet required to create invoice'),
      );
    }

    try {
      final result = await _invoiceRemoteDatasource.createInvoice(
        InvoiceApiModel.fromEntity(invoice),
      );
      if (result == null) {
        return const Left(ApiFailure(message: 'Failed to create invoice'));
      }
      return Right(result.toEntity());
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}
