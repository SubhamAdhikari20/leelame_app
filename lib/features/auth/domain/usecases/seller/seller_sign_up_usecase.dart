// lib/features/auth/domain/usecases/seller/seller_sign_up_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/core/usecases/app_usecase.dart';
import 'package:leelame/features/auth/data/repositories/seller_auth_repository.dart';
import 'package:leelame/features/auth/domain/entities/user_entity.dart';
import 'package:leelame/features/auth/domain/repositories/seller_auth_repository.dart';
import 'package:leelame/features/seller/domain/entities/seller_entity.dart';
import 'package:uuid/uuid.dart';

class SellerSignUpUsecaseParams extends Equatable {
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? password;
  final String? userId;

  const SellerSignUpUsecaseParams({
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.password,
    this.userId,
  });

  @override
  List<Object?> get props => [fullName, email, phoneNumber, password, userId];
}

// Provider for SignUp Usecase
final sellerSignUpUsecaseProvider = Provider<SellerSignUpUsecase>((ref) {
  final sellerAuthRepository = ref.read(sellerAuthRepositoryProvider);
  return SellerSignUpUsecase(sellerAuthRepository: sellerAuthRepository);
});

class SellerSignUpUsecase
    implements UsecaseWithParams<SellerEntity, SellerSignUpUsecaseParams> {
  final ISellerAuthRepository _sellerAuthRepository;

  SellerSignUpUsecase({required ISellerAuthRepository sellerAuthRepository})
    : _sellerAuthRepository = sellerAuthRepository;

  @override
  Future<Either<Failures, SellerEntity>> call(
    SellerSignUpUsecaseParams params,
  ) async {
    // Generate userId
    final userId = params.userId ?? Uuid().v4();

    // create user and seller entities
    UserEntity userEntity = UserEntity(
      userId: userId,
      email: params.email,
      role: "seller",
      isVerified: false,
      isPermanentlyBanned: false,
    );

    SellerEntity sellerEntity = SellerEntity(
      fullName: params.fullName,
      phoneNumber: params.phoneNumber,
      password: params.password,
      userId: userId,
    );

    return await _sellerAuthRepository.signUp(userEntity, sellerEntity);
  }
}
