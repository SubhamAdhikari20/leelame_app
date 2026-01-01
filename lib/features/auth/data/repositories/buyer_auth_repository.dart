// lib/features/auth/data/repositories/buyer_auth_repository.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/features/auth/data/datasources/buyer_auth_datasource.dart';
import 'package:leelame/features/auth/data/datasources/local/buyer_auth_local_datasource.dart';
import 'package:leelame/features/auth/data/models/user_hive_model.dart';
import 'package:leelame/features/auth/domain/entities/user_entity.dart';
import 'package:leelame/features/auth/domain/repositories/buyer_auth_repository.dart';
import 'package:leelame/features/buyer/data/models/buyer_hive_model.dart';
import 'package:leelame/features/buyer/domain/entities/buyer_entity.dart';

final buyerAuthRepositoryProvider = Provider<IBuyerAuthRepository>((ref) {
  final buyerAuthDatasource = ref.read(buyerAuthLocalDatasourceProvider);
  return BuyerAuthRepository(buyerAuthDatasource: buyerAuthDatasource);
});

class BuyerAuthRepository implements IBuyerAuthRepository {
  final IBuyerAuthDatasource _buyerAuthDatasource;

  BuyerAuthRepository({required IBuyerAuthDatasource buyerAuthDatasource})
    : _buyerAuthDatasource = buyerAuthDatasource;
  @override
  Future<Either<Failures, BuyerEntity>> login(
    String identifier,
    String password,
  ) async {
    try {
      final buyer = await _buyerAuthDatasource.login(identifier, password);
      if (buyer == null) {
        return const Left(
          LocalDatabaseFailure(message: "Failed to login buyer!"),
        );
      }

      final user = await _buyerAuthDatasource.getCurrentUser(buyer.userId!);
      if (user == null) {
        return const Left(
          LocalDatabaseFailure(message: "Failed to get current base user!"),
        );
      }

      return Right(buyer.toEntity(userEntity: user.toEntity()));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failures, bool>> logout() async {
    try {
      final result = await _buyerAuthDatasource.logout();
      if (!result) {
        return const Left(
          LocalDatabaseFailure(message: "Failed to logout buyer!"),
        );
      }

      return const Right(true);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failures, BuyerEntity>> signUp(
    UserEntity userEntity,
    BuyerEntity buyerEntity,
  ) async {
    try {
      final userModel = UserHiveModel.fromEntity(userEntity);
      final buyerModel = BuyerHiveModel.fromEntity(buyerEntity);

      final result = await _buyerAuthDatasource.signUp(userModel, buyerModel);
      if (result == null) {
        return const Left(
          LocalDatabaseFailure(message: "Failed to sign up buyer!"),
        );
      }

      return Right(result.toEntity(userEntity: userEntity));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failures, BuyerEntity>> getCurrentBuyer(String buyerId) async {
    try {
      final buyer = await _buyerAuthDatasource.getCurrentBuyer(buyerId);
      if (buyer == null) {
        return const Left(
          LocalDatabaseFailure(message: "Failed to get current buyer!"),
        );
      }

      final user = await _buyerAuthDatasource.getCurrentUser(buyer.userId!);
      if (user == null) {
        return const Left(
          LocalDatabaseFailure(message: "Failed to get current base user!"),
        );
      }

      return Right(buyer.toEntity(userEntity: user.toEntity()));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }
}
