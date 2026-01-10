// lib/features/auth/domain/usecases/buyer_login_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/core/usecases/app_usecase.dart';
import 'package:leelame/features/auth/data/repositories/buyer_auth_repository.dart';
import 'package:leelame/features/auth/domain/repositories/buyer_auth_repository.dart';
import 'package:leelame/features/buyer/domain/entities/buyer_entity.dart';

class BuyerLoginUsecaseParams extends Equatable {
  final String identifier;
  final String password;
  final String role;

  const BuyerLoginUsecaseParams({
    required this.identifier,
    required this.password,
    required this.role,
  });

  @override
  List<Object?> get props => [identifier, password, role];
}

// Provider for Login Usecase
final buyerLoginUsecaseProvider = Provider<BuyerLoginUsecase>((ref) {
  final buyerAuthRepository = ref.read(buyerAuthRepositoryProvider);
  return BuyerLoginUsecase(buyerAuthRepository: buyerAuthRepository);
});

class BuyerLoginUsecase
    implements UsecaseWithParams<BuyerEntity, BuyerLoginUsecaseParams> {
  final IBuyerAuthRepository _buyerAuthRepository;

  BuyerLoginUsecase({required IBuyerAuthRepository buyerAuthRepository})
    : _buyerAuthRepository = buyerAuthRepository;

  @override
  Future<Either<Failures, BuyerEntity>> call(
    BuyerLoginUsecaseParams params,
  ) async {
    return await _buyerAuthRepository.login(
      params.identifier,
      params.password,
      params.role,
    );
  }
}
