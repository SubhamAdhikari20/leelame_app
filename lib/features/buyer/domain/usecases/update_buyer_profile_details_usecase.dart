// lib/features/buyer/domain/usecases/update_buyer_profile_details_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/core/usecases/app_usecase.dart';
import 'package:leelame/features/buyer/data/repositories/buyer_repository.dart';
import 'package:leelame/features/buyer/domain/entities/buyer_entity.dart';
import 'package:leelame/features/buyer/domain/repositories/buyer_repository.dart';

class UpdateBuyerProfileDetailsUsecaseParams extends Equatable {
  final String buyerId;
  final String? fullName;
  final String? email;
  final String? username;
  final String? phoneNumber;
  final String? bio;

  const UpdateBuyerProfileDetailsUsecaseParams({
    required this.buyerId,
    this.fullName,
    this.email,
    this.username,
    this.phoneNumber,
    this.bio,
  });

  @override
  List<Object?> get props => [fullName, username, email, phoneNumber, bio];
}

final updateBuyerProfileDetailsUsecaseProvider =
    Provider<UpdateBuyerProfileDetailsUsecase>((ref) {
      final buyerRepository = ref.read(buyerRepositoryProvider);
      return UpdateBuyerProfileDetailsUsecase(buyerRepository: buyerRepository);
    });

class UpdateBuyerProfileDetailsUsecase
    implements
        UsecaseWithParams<BuyerEntity, UpdateBuyerProfileDetailsUsecaseParams> {
  final IBuyerRepository _buyerRepository;

  UpdateBuyerProfileDetailsUsecase({required IBuyerRepository buyerRepository})
    : _buyerRepository = buyerRepository;

  @override
  Future<Either<Failures, BuyerEntity>> call(
    UpdateBuyerProfileDetailsUsecaseParams params,
  ) async {
    final currentResult = await _buyerRepository.getCurrentBuyer(
      params.buyerId,
    );

    return currentResult.fold(
      (failure) {
        return Left(failure);
      },
      (currentBuyer) async {
        final updatedBaseUser = currentBuyer.userEntity?.copyWith(
          email: params.email,
        );

        final updatedBuyer = currentBuyer.copyWith(
          fullName: params.fullName,
          username: params.username,
          phoneNumber: params.phoneNumber,
          bio: params.bio,
          userEntity: updatedBaseUser,
        );

        return await _buyerRepository.updateBuyer(updatedBuyer);
      },
    );
  }
}
