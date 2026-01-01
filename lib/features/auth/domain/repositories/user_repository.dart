// lib/features/auth/domain/repositories/user_repository.dart
import 'package:dartz/dartz.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/features/auth/domain/entities/user_entity.dart';

abstract interface class IUserRepository {
  Future<Either<Failures, UserEntity?>> createUser(UserEntity userEntity);
  Future<Either<Failures, UserEntity?>> updateUser(UserEntity userEntity);
  Future<Either<Failures, UserEntity?>> getUserById(String userId);
  Future<Either<Failures, List<UserEntity>>> getAllUsers();
  Future<Either<Failures, void>> deleteUser(String userId);
  Future<Either<Failures, void>> deleteAllUsers();
}
