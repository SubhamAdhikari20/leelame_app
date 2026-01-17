// lib/features/auth/domain/usecases/buyer_verify_account_registration_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/core/usecases/app_usecase.dart';
import 'package:leelame/features/auth/data/repositories/buyer_auth_repository.dart';
import 'package:leelame/features/auth/domain/repositories/buyer_auth_repository.dart';

class BuyerVerifyAccountRegistrationUsecaseParams extends Equatable {
  final String username;
  final String otp;

  const BuyerVerifyAccountRegistrationUsecaseParams({
    required this.username,
    required this.otp,
  });

  @override
  List<Object?> get props => [username, otp];
}

// Provider for Verify Account for Registration Usecase
final buyerVerifyAccountRegistrationUsecaseProvider =
    Provider<BuyerVerifyAccountRegistrationUsecase>((ref) {
      final buyerAuthRepository = ref.read(buyerAuthRepositoryProvider);
      return BuyerVerifyAccountRegistrationUsecase(
        buyerAuthRepository: buyerAuthRepository,
      );
    });

class BuyerVerifyAccountRegistrationUsecase
    implements
        UsecaseWithParams<bool, BuyerVerifyAccountRegistrationUsecaseParams> {
  final IBuyerAuthRepository _buyerAuthRepository;

  BuyerVerifyAccountRegistrationUsecase({
    required IBuyerAuthRepository buyerAuthRepository,
  }) : _buyerAuthRepository = buyerAuthRepository;

  @override
  Future<Either<Failures, bool>> call(
    BuyerVerifyAccountRegistrationUsecaseParams params,
  ) async {
    return await _buyerAuthRepository.verifyAccountRegistration(
      params.username,
      params.otp,
    );
  }
}
