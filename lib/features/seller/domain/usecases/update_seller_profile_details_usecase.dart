// lib/features/seller/domain/usecases/update_seller_profile_details_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/core/usecases/app_usecase.dart';
import 'package:leelame/features/seller/data/repositories/seller_repository.dart';
import 'package:leelame/features/seller/domain/entities/seller_entity.dart';
import 'package:leelame/features/seller/domain/repositories/seller_repository.dart';

class UpdateSellerProfileDetailsUsecaseParams extends Equatable {
  final String sellerId;
  final String? fullName;
  final String? email;
  final String? username;
  final String? phoneNumber;
  final String? bio;

  const UpdateSellerProfileDetailsUsecaseParams({
    required this.sellerId,
    this.fullName,
    this.email,
    this.username,
    this.phoneNumber,
    this.bio,
  });

  @override
  List<Object?> get props => [fullName, username, email, phoneNumber, bio];
}

final updateSellerProfileDetailsUsecaseProvider =
    Provider<UpdateSellerProfileDetailsUsecase>((ref) {
      final sellerRepository = ref.read(sellerRepositoryProvider);
      return UpdateSellerProfileDetailsUsecase(
        sellerRepository: sellerRepository,
      );
    });

class UpdateSellerProfileDetailsUsecase
    implements
        UsecaseWithParams<
          SellerEntity,
          UpdateSellerProfileDetailsUsecaseParams
        > {
  final ISellerRepository _sellerRepository;

  UpdateSellerProfileDetailsUsecase({
    required ISellerRepository sellerRepository,
  }) : _sellerRepository = sellerRepository;

  @override
  Future<Either<Failures, SellerEntity>> call(
    UpdateSellerProfileDetailsUsecaseParams params,
  ) async {
    final currentResult = await _sellerRepository.getCurrentSeller(
      params.sellerId,
    );

    return currentResult.fold(
      (failure) {
        return Left(failure);
      },
      (currentSeller) async {
        final updatedBaseUser = currentSeller.userEntity?.copyWith(
          email: params.email,
        );

        final updatedSeller = currentSeller.copyWith(
          fullName: params.fullName,
          phoneNumber: params.phoneNumber,
          bio: params.bio,
          userEntity: updatedBaseUser,
        );

        return await _sellerRepository.updateSeller(updatedSeller);
      },
    );
  }
}
