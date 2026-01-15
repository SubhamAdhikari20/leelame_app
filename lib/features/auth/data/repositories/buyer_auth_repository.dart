// lib/features/auth/data/repositories/buyer_auth_repository.dart
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/core/services/connectivity/network_info.dart';
import 'package:leelame/features/auth/data/datasources/buyer_auth_datasource.dart';
import 'package:leelame/features/auth/data/datasources/local/buyer_auth_local_datasource.dart';
import 'package:leelame/features/auth/data/datasources/remote/buyer_auth_remote_datasource.dart';
import 'package:leelame/features/auth/data/models/user_api_model.dart';
import 'package:leelame/features/auth/data/models/user_hive_model.dart';
import 'package:leelame/features/auth/domain/entities/user_entity.dart';
import 'package:leelame/features/auth/domain/repositories/buyer_auth_repository.dart';
import 'package:leelame/features/buyer/data/models/buyer_api_model.dart';
import 'package:leelame/features/buyer/data/models/buyer_hive_model.dart';
import 'package:leelame/features/buyer/domain/entities/buyer_entity.dart';

final buyerAuthRepositoryProvider = Provider<IBuyerAuthRepository>((ref) {
  final buyerAuthLocalDatasource = ref.read(buyerAuthLocalDatasourceProvider);
  final buyerAuthRemoteDatasource = ref.read(buyerAuthRemoteDatasourceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  return BuyerAuthRepository(
    buyerAuthLocalDatasource: buyerAuthLocalDatasource,
    buyerAuthRemoteDatasource: buyerAuthRemoteDatasource,
    networkInfo: networkInfo,
  );
});

class BuyerAuthRepository implements IBuyerAuthRepository {
  final IBuyerAuthLocalDatasource _buyerAuthLocalDatasource;
  final IBuyerAuthRemoteDatasource _buyerAuthRemoteDatasource;
  final INetworkInfo _networkInfo;

  BuyerAuthRepository({
    required IBuyerAuthLocalDatasource buyerAuthLocalDatasource,
    required IBuyerAuthRemoteDatasource buyerAuthRemoteDatasource,
    required INetworkInfo networkInfo,
  }) : _buyerAuthLocalDatasource = buyerAuthLocalDatasource,
       _buyerAuthRemoteDatasource = buyerAuthRemoteDatasource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failures, BuyerEntity>> signUp(
    UserEntity userEntity,
    BuyerEntity buyerEntity,
  ) async {
    // Check for internet connection
    if (await _networkInfo.isConnected) {
      try {
        final userModel = UserApiModel.fromEntity(userEntity);
        final buyerModel = BuyerApiModel.fromEntity(buyerEntity);

        final result = await _buyerAuthRemoteDatasource.signUp(
          userModel,
          buyerModel,
        );
        if (result == null) {
          return const Left(ApiFailure(message: "Failed to sign up buyer!"));
        }

        return Right(result.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message: e.response?.data["message"] ?? "Failed to sign up buyer!",
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final userModel = UserHiveModel.fromEntity(userEntity);
        final buyerModel = BuyerHiveModel.fromEntity(buyerEntity);

        final checkEmailExist = await _buyerAuthLocalDatasource.isEmailExists(
          userModel.email,
        );
        if (checkEmailExist) {
          return const Left(
            LocalDatabaseFailure(
              message: "Sign Up failed! Email already exists.",
            ),
          );
        }

        final checkUsernameExist = await _buyerAuthLocalDatasource
            .isUsernameExists(buyerModel.username!);
        if (checkUsernameExist) {
          return const Left(
            LocalDatabaseFailure(
              message: "Sign Up failed! Username already exists.",
            ),
          );
        }

        final checkPhoneNumberExist = await _buyerAuthLocalDatasource
            .isPhoneNumberExists(buyerModel.phoneNumber!);
        if (checkPhoneNumberExist) {
          return const Left(
            LocalDatabaseFailure(
              message: "Sign Up failed! Phone Number already exists.",
            ),
          );
        }

        final result = await _buyerAuthLocalDatasource.signUp(
          userModel,
          buyerModel,
        );
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
  }

  @override
  Future<Either<Failures, BuyerEntity>> login(
    String identifier,
    String password,
    String role,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _buyerAuthRemoteDatasource.login(
          identifier,
          password,
          role,
        );
        if (result == null) {
          return const Left(ApiFailure(message: "Failed to login buyer!"));
        }

        return Right(result.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message: e.response?.data["message"] ?? "Failed to login buyer!",
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final buyer = await _buyerAuthLocalDatasource.login(
          identifier,
          password,
          role,
        );
        if (buyer == null) {
          return const Left(
            LocalDatabaseFailure(message: "Failed to login buyer!"),
          );
        }

        final baseUser = await _buyerAuthLocalDatasource.getCurrentUser(
          buyer.userId!,
        );
        if (baseUser == null) {
          return const Left(
            LocalDatabaseFailure(message: "Failed to get current base user!"),
          );
        }

        return Right(buyer.toEntity(userEntity: baseUser.toEntity()));
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failures, bool>> logout() async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _buyerAuthRemoteDatasource.logout();
        if (!result) {
          return const Left(ApiFailure(message: "Failed to logout buyer!"));
        }

        return Right(result);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message: e.response?.data["message"] ?? "Failed to logout buyer!",
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final result = await _buyerAuthLocalDatasource.logout();
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
  }

  @override
  Future<Either<Failures, BuyerEntity>> getCurrentBuyer(String buyerId) async {
    if (await _networkInfo.isConnected) {
      try {
        final buyer = await _buyerAuthRemoteDatasource.getCurrentBuyer(buyerId);
        if (buyer == null) {
          return const Left(
            ApiFailure(message: "Failed to get current buyer!"),
          );
        }

        return Right(buyer.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            statusCode: e.response?.statusCode,
            message:
                e.response?.data["message"] ?? "Failed to get current buyer!",
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final buyer = await _buyerAuthLocalDatasource.getCurrentBuyer(buyerId);
        if (buyer == null) {
          return const Left(
            LocalDatabaseFailure(message: "Failed to get current buyer!"),
          );
        }

        final user = await _buyerAuthLocalDatasource.getCurrentUser(
          buyer.userId!,
        );
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
}
