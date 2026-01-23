// lib/features/auth/domain/repositories/seller_auth_repository.dart
import 'package:dartz/dartz.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/features/auth/domain/entities/user_entity.dart';
import 'package:leelame/features/seller/domain/entities/seller_entity.dart';

abstract interface class ISellerAuthRepository {
  Future<Either<Failures, SellerEntity>> signUp(
    UserEntity userEntity,
    SellerEntity sellerEntity,
  );
  Future<Either<Failures, bool>> verifyAccountRegistration(
    String email,
    String otp,
  );
  Future<Either<Failures, SellerEntity>> login(
    String identifier,
    String password,
    String role,
  );
  Future<Either<Failures, SellerEntity>> getCurrentSeller(String sellerId);
  Future<Either<Failures, bool>> logout();
}
