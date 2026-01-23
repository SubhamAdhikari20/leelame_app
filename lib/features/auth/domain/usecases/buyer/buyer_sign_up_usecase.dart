// lib/features/auth/domain/usecases/buyer/buyer_sign_up_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/core/usecases/app_usecase.dart';
import 'package:leelame/features/auth/data/repositories/buyer_auth_repository.dart';
import 'package:leelame/features/auth/domain/entities/user_entity.dart';
import 'package:leelame/features/auth/domain/repositories/buyer_auth_repository.dart';
import 'package:leelame/features/buyer/domain/entities/buyer_entity.dart';
import 'package:uuid/uuid.dart';

// Buyer Sign Up Params
class BuyerSignUpUsecaseParams extends Equatable {
  final String fullName;
  final String email;
  final String? username;
  final String? phoneNumber;
  final String? password;
  final bool termsAccepted;
  final String? userId;

  const BuyerSignUpUsecaseParams({
    required this.fullName,
    required this.email,
    this.username,
    this.phoneNumber,
    this.password,
    required this.termsAccepted,
    this.userId,
  });

  @override
  List<Object?> get props => [
    fullName,
    username,
    email,
    phoneNumber,
    password,
    userId,
  ];
}

// Provider for SignUp Usecase
final buyerSignUpUsecaseProvider = Provider<BuyerSignUpUsecase>((ref) {
  final buyerAuthRepository = ref.read(buyerAuthRepositoryProvider);
  return BuyerSignUpUsecase(buyerAuthRepository: buyerAuthRepository);
});

// Buyer SignUp Usecase
class BuyerSignUpUsecase
    implements UsecaseWithParams<BuyerEntity, BuyerSignUpUsecaseParams> {
  final IBuyerAuthRepository _buyerAuthRepository;

  BuyerSignUpUsecase({required IBuyerAuthRepository buyerAuthRepository})
    : _buyerAuthRepository = buyerAuthRepository;

  @override
  Future<Either<Failures, BuyerEntity>> call(
    BuyerSignUpUsecaseParams params,
  ) async {
    // Validate email, username, phoneNumber fields
    if (params.email.isEmpty) {
      return const Left(ValidationFailure(message: "Email is required."));
    }
    if (params.username == null || params.username!.isEmpty) {
      return const Left(ValidationFailure(message: "Username is required."));
    }
    if (params.phoneNumber == null || params.phoneNumber!.isEmpty) {
      return const Left(
        ValidationFailure(message: "Phone number is required."),
      );
    }
    // if (params.password == null || params.password!.isEmpty) {
    //   return const Left(ValidationFailure(message: "Password is required."));
    // }

    // Generate userId
    final userId = params.userId ?? Uuid().v4();

    // create user and buyer entities
    UserEntity userEntity = UserEntity(
      userId: userId,
      email: params.email,
      role: "buyer",
      isVerified: false,
      isPermanentlyBanned: false,
    );

    BuyerEntity buyerEntity = BuyerEntity(
      fullName: params.fullName,
      username: params.username,
      phoneNumber: params.phoneNumber,
      password: params.password,
      termsAccepted: params.termsAccepted,
      userId: userId,
    );

    return await _buyerAuthRepository.signUp(userEntity, buyerEntity);
  }
}
