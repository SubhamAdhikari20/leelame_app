import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/core/services/connectivity/network_info.dart';
import 'package:leelame/features/payment/data/datasources/payment_datasource.dart';
import 'package:leelame/features/payment/data/datasources/remote/payment_remote_datasource.dart';
import 'package:leelame/features/payment/data/models/payment_api_model.dart';
import 'package:leelame/features/payment/domain/entities/payment_entity.dart';
import 'package:leelame/features/payment/domain/repositories/payment_repository.dart';

final paymentRepositoryProvider = Provider<IPaymentRepository>((ref) {
  return PaymentRepository(
    remoteDatasource: ref.read(paymentRemoteDatasourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class PaymentRepository implements IPaymentRepository {
  final IPaymentRemoteDatasource _remoteDatasource;
  final INetworkInfo _networkInfo;

  PaymentRepository({
    required IPaymentRemoteDatasource remoteDatasource,
    required INetworkInfo networkInfo,
  }) : _remoteDatasource = remoteDatasource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failures, PaymentEntity>> initiatePayment(
    PaymentEntity payment,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'Internet required to initiate payment'),
      );
    }

    try {
      final result = await _remoteDatasource.initiatePayment(
        PaymentApiModel.fromEntity(payment),
      );
      if (result == null) {
        return const Left(ApiFailure(message: 'Failed to initiate payment'));
      }
      return Right(result.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          statusCode: e.response?.statusCode,
          message:
              e.response?.data['message']?.toString() ??
              'Failed to initiate payment',
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failures, PaymentEntity>> processTestGatewayPayment({
    required String orderId,
    required PaymentMethod method,
    required double amount,
  }) {
    // TODO: implement processTestGatewayPayment
    throw UnimplementedError();
  }

  @override
  Future<Either<Failures, PaymentEntity>> verifyPayment({
    required String orderId,
    required String transactionId,
    required PaymentMethod method,
  }) {
    // TODO: implement verifyPayment
    throw UnimplementedError();
  }
}
