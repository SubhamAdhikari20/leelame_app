// lib/features/auth/domain/usecases/seller/seller_logout_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/core/usecases/app_usecase.dart';
import 'package:leelame/features/auth/data/repositories/seller_auth_repository.dart';
import 'package:leelame/features/auth/domain/repositories/seller_auth_repository.dart';

// Provider for Logout Usecase
final sellerLogoutUsecaseProvider = Provider<SellerLogoutUsecase>((ref) {
  final sellerAuthRepository = ref.read(sellerAuthRepositoryProvider);
  return SellerLogoutUsecase(sellerAuthRepository: sellerAuthRepository);
});

class SellerLogoutUsecase implements UsecaseWithoutParams<bool> {
  final ISellerAuthRepository _sellerAuthRepository;

  SellerLogoutUsecase({required ISellerAuthRepository sellerAuthRepository})
    : _sellerAuthRepository = sellerAuthRepository;

  @override
  Future<Either<Failures, bool>> call() async {
    return await _sellerAuthRepository.logout();
  }
}
