// lib/features/auth/domain/usecases/seller/seller_login_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/core/usecases/app_usecase.dart';
import 'package:leelame/features/auth/data/repositories/seller_auth_repository.dart';
import 'package:leelame/features/auth/domain/repositories/seller_auth_repository.dart';
import 'package:leelame/features/seller/domain/entities/seller_entity.dart';

class SellerLoginUsecaseParams extends Equatable {
  final String identifier;
  final String password;
  final String role;

  const SellerLoginUsecaseParams({
    required this.identifier,
    required this.password,
    required this.role,
  });

  @override
  List<Object?> get props => [identifier, password, role];
}

// Provider for Login Usecase
final sellerLoginUsecaseProvider = Provider<SellerLoginUsecase>((ref) {
  final sellerAuthRepository = ref.read(sellerAuthRepositoryProvider);
  return SellerLoginUsecase(sellerAuthRepository: sellerAuthRepository);
});

class SellerLoginUsecase
    implements UsecaseWithParams<SellerEntity, SellerLoginUsecaseParams> {
  final ISellerAuthRepository _sellerAuthRepository;

  SellerLoginUsecase({required ISellerAuthRepository sellerAuthRepository})
    : _sellerAuthRepository = sellerAuthRepository;

  @override
  Future<Either<Failures, SellerEntity>> call(
    SellerLoginUsecaseParams params,
  ) async {
    return await _sellerAuthRepository.login(
      params.identifier,
      params.password,
      params.role,
    );
  }
}
