// lib/features/invoice/data/datasource/invoice_datasource.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/api/api_client.dart';
import 'package:leelame/core/api/api_endpoints.dart';
import 'package:leelame/core/services/storage/token_service.dart';
import 'package:leelame/features/invoice/data/datasource/invoice_datasource.dart';
import 'package:leelame/features/invoice/data/models/invoice_api_model.dart';

final invoiceRemoteDatasourceProvider = Provider<IInvoiceRemoteDatasource>((
  ref,
) {
  return InvoiceRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

class InvoiceRemoteDatasource implements IInvoiceRemoteDatasource {
  final ApiClient _apiClient;
  final TokenService _tokenService;

  InvoiceRemoteDatasource({
    required ApiClient apiClient,
    required TokenService tokenService,
  }) : _apiClient = apiClient,
       _tokenService = tokenService;

  @override
  Future<InvoiceApiModel?> createInvoice(InvoiceApiModel invoiceModel) async {
    final token = _tokenService.getToken();
    final response = await _apiClient.post(
      ApiEndpoints.createInvoice,
      data: invoiceModel.toJson(),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    final success = response.data['success'] as bool? ?? false;
    final data = response.data['data'] as Map<String, dynamic>?;

    if (!success || data == null) {
      return null;
    }

    return InvoiceApiModel.fromJson(response.data);
  }
}
