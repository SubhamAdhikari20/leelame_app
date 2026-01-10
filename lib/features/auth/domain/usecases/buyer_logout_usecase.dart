// lib/features/auth/domain/usecases/buyer_logout_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/core/usecases/app_usecase.dart';
import 'package:leelame/features/auth/data/repositories/buyer_auth_repository.dart';
import 'package:leelame/features/auth/domain/repositories/buyer_auth_repository.dart';

// Provider for Logout Usecase
final buyerLogoutUsecaseProvider = Provider<BuyerLogoutUsecase>((ref) {
  final buyerAuthRepository = ref.read(buyerAuthRepositoryProvider);
  return BuyerLogoutUsecase(buyerAuthRepository: buyerAuthRepository);
});

class BuyerLogoutUsecase implements UsecaseWithoutParams {
  final IBuyerAuthRepository _buyerAuthRepository;

  BuyerLogoutUsecase({required IBuyerAuthRepository buyerAuthRepository})
    : _buyerAuthRepository = buyerAuthRepository;

  @override
  Future<Either<Failures, bool>> call() async {
    return await _buyerAuthRepository.logout();
  }
}
