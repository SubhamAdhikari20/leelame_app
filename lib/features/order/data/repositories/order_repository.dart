import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/core/services/connectivity/network_info.dart';
import 'package:leelame/features/order/data/datasources/order_datasource.dart';
import 'package:leelame/features/order/data/datasources/remote/order_remote_datasource.dart';
import 'package:leelame/features/order/data/models/order_api_model.dart';
import 'package:leelame/features/order/domain/entities/order_entity.dart';
import 'package:leelame/features/order/domain/repositories/order_repository.dart';

final orderRepositoryProvider = Provider<IOrderRepository>((ref) {
  return OrderRepository(
    remoteDatasource: ref.read(orderRemoteDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class OrderRepository implements IOrderRepository {
  final IOrderRemoteDatasource _remoteDatasource;
  final INetworkInfo _networkInfo;

  OrderRepository({
    required IOrderRemoteDatasource remoteDatasource,
    required INetworkInfo networkInfo,
  }) : _remoteDatasource = remoteDatasource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failures, OrderEntity>> createOrder(OrderEntity order) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'Internet required to create order'),
      );
    }

    try {
      final result = await _remoteDatasource.createOrder(
        OrderApiModel.fromEntity(order),
      );
      if (result == null) {
        return const Left(ApiFailure(message: 'Failed to create order'));
      }
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          statusCode: e.response?.statusCode,
          message:
              e.response?.data['message']?.toString() ??
              'Failed to create order',
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failures, OrderEntity>> getOrderById(String orderId) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'Internet required to get order'),
      );
    }

    try {
      final result = await _remoteDatasource.getOrderById(orderId);
      if (result == null) {
        return const Left(ApiFailure(message: 'Failed to get order'));
      }
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          statusCode: e.response?.statusCode,
          message:
              e.response?.data['message']?.toString() ?? 'Failed to get order',
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failures, OrderEntity>> updateOrderDetails(
    OrderEntity orderEntity,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'Internet required to update order'),
      );
    }

    try {
      final result = await _remoteDatasource.updateOrderDetails(
        OrderApiModel.fromEntity(orderEntity),
      );
      if (result == null) {
        return const Left(ApiFailure(message: 'Failed to update order'));
      }
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          statusCode: e.response?.statusCode,
          message:
              e.response?.data['message']?.toString() ??
              'Failed to update order',
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failures, OrderEntity>> updateOrderStatus(
    String orderId,
    OrderStatus orderStatus,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'Internet required to update order status'),
      );
    }

    try {
      final result = await _remoteDatasource.updateOrderStatus(
        orderId,
        orderStatus,
      );
      if (result == null) {
        return const Left(ApiFailure(message: 'Failed to update order status'));
      }
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          statusCode: e.response?.statusCode,
          message:
              e.response?.data['message']?.toString() ??
              'Failed to update order status',
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}
