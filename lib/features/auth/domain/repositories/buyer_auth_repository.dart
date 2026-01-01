// lib/features/auth/domain/repositories/buyer_auth_repository.dart
import 'package:dartz/dartz.dart';
import 'package:leelame/core/error/failures.dart';
// import 'package:leelame/features/auth/domain/entities/buyer_auth_entity.dart';
import 'package:leelame/features/auth/domain/entities/user_entity.dart';
import 'package:leelame/features/buyer/domain/entities/buyer_entity.dart';

abstract interface class IBuyerAuthRepository {
  Future<Either<Failures, BuyerEntity>> signUp(
    UserEntity userEntity,
    BuyerEntity buyerEntity,
  );
  Future<Either<Failures, BuyerEntity>> login(
    String identifier,
    String password,
    String role,
  );
  Future<Either<Failures, BuyerEntity>> getCurrentUser();
  Future<Either<Failures, BuyerEntity>> verifyAccountRegistration();
  Future<Either<Failures, BuyerEntity>> forgotPassword();
  Future<Either<Failures, BuyerEntity>> verifyAccountResetPassword();
  Future<Either<Failures, BuyerEntity>> resetPassword();
  Future<Either<Failures, bool>> logout();
}
