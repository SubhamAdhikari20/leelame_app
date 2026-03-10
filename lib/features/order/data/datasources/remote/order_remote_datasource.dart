import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/api/api_client.dart';
import 'package:leelame/core/api/api_endpoints.dart';
import 'package:leelame/core/services/storage/token_service.dart';
import 'package:leelame/features/order/data/datasources/order_datasource.dart';
import 'package:leelame/features/order/data/models/order_api_model.dart';
import 'package:leelame/features/order/domain/entities/order_entity.dart';

final orderRemoteDatasourceProvider = Provider<IOrderRemoteDatasource>((ref) {
  return OrderRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    tokenService: ref.read(tokenServiceProvider),
  );
});

class OrderRemoteDatasource implements IOrderRemoteDatasource {
  final ApiClient _apiClient;
  final TokenService _tokenService;

  OrderRemoteDatasource({
    required ApiClient apiClient,
    required TokenService tokenService,
  }) : _apiClient = apiClient,
       _tokenService = tokenService;

  @override
  Future<OrderApiModel?> createOrder(OrderApiModel orderModel) async {
    final token = _tokenService.getToken();
    final response = await _apiClient.post(
      ApiEndpoints.createOrder,
      data: orderModel.toJson(),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    final success = response.data['success'] as bool? ?? false;
    final data = response.data['data'] as Map<String, dynamic>?;

    if (!success || data == null) {
      return null;
    }

    return OrderApiModel.fromJson(data);
  }

  @override
  Future<OrderApiModel?> getOrderById(String orderId) async {
    final token = _tokenService.getToken();
    final response = await _apiClient.get(
      ApiEndpoints.orderById(orderId),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    final success = response.data['success'] as bool? ?? false;
    final data = response.data['data'] as Map<String, dynamic>?;

    if (!success || data == null) {
      return null;
    }

    return OrderApiModel.fromJson(data);
  }

  @override
  Future<OrderApiModel?> updateOrderDetails(OrderApiModel orderModel) async {
    final token = _tokenService.getToken();
    final response = await _apiClient.put(
      ApiEndpoints.updateOrderDetails(orderModel.id!),
      data: orderModel.toJson(),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    final success = response.data['success'] as bool? ?? false;
    final data = response.data['data'] as Map<String, dynamic>?;

    if (!success || data == null) {
      return null;
    }

    return OrderApiModel.fromJson(data);
  }

  @override
  Future<OrderApiModel?> updateOrderStatus(
    String orderId,
    OrderStatus status,
  ) async {
    final token = _tokenService.getToken();
    final response = await _apiClient.put(
      ApiEndpoints.updateOrderStatus(orderId),
      data: {'status': status.name},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    final success = response.data['success'] as bool? ?? false;
    final data = response.data['data'] as Map<String, dynamic>?;

    if (!success || data == null) {
      return null;
    }

    return OrderApiModel.fromJson(data);
  }
}
