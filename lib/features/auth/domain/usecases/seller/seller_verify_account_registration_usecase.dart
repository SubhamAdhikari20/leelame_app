// lib/features/auth/domain/usecases/seller/seller_verify_account_registration_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/core/usecases/app_usecase.dart';
import 'package:leelame/features/auth/data/repositories/seller_auth_repository.dart';
import 'package:leelame/features/auth/domain/repositories/seller_auth_repository.dart';

class SellerVerifyAccountRegistrationUsecaseParams extends Equatable {
  final String email;
  final String otp;

  const SellerVerifyAccountRegistrationUsecaseParams({
    required this.email,
    required this.otp,
  });

  @override
  List<Object?> get props => [email, otp];
}

// Provider for Verify Account for Registration Usecase
final sellerVerifyAccountRegistrationUsecaseProvider =
    Provider<SellerVerifyAccountRegistrationUsecase>((ref) {
      final sellerAuthRepository = ref.read(sellerAuthRepositoryProvider);
      return SellerVerifyAccountRegistrationUsecase(
        sellerAuthRepository: sellerAuthRepository,
      );
    });

class SellerVerifyAccountRegistrationUsecase
    implements
        UsecaseWithParams<bool, SellerVerifyAccountRegistrationUsecaseParams> {
  final ISellerAuthRepository _sellerAuthRepository;

  SellerVerifyAccountRegistrationUsecase({
    required ISellerAuthRepository sellerAuthRepository,
  }) : _sellerAuthRepository = sellerAuthRepository;

  @override
  Future<Either<Failures, bool>> call(
    SellerVerifyAccountRegistrationUsecaseParams params,
  ) async {
    return await _sellerAuthRepository.verifyAccountRegistration(
      params.email,
      params.otp,
    );
  }
}
