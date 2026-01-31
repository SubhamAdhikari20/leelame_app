// lib/features/buyer/domain/usecases/upload_buyer_profile_picture_usecase.dart
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/core/usecases/app_usecase.dart';
import 'package:leelame/features/buyer/data/repositories/buyer_repository.dart';
import 'package:leelame/features/buyer/domain/repositories/buyer_repository.dart';

class UploadBuyerProfilePictureUsecaseParams extends Equatable {
  final String buyerId;
  final File profilePicture;

  const UploadBuyerProfilePictureUsecaseParams({
    required this.buyerId,
    required this.profilePicture,
  });

  @override
  List<Object?> get props => [profilePicture];
}

final uploadBuyerProfilePictureUsecaseProvider =
    Provider<UploadBuyerProfilePictureUsecase>((ref) {
      final buyerRepository = ref.read(buyerRepositoryProvider);
      return UploadBuyerProfilePictureUsecase(buyerRepository: buyerRepository);
    });

class UploadBuyerProfilePictureUsecase
    implements
        UsecaseWithParams<String, UploadBuyerProfilePictureUsecaseParams> {
  final IBuyerRepository _buyerRepository;

  UploadBuyerProfilePictureUsecase({required IBuyerRepository buyerRepository})
    : _buyerRepository = buyerRepository;

  @override
  Future<Either<Failures, String>> call(
    UploadBuyerProfilePictureUsecaseParams params,
  ) async {
    return await _buyerRepository.uploadBuyerProfilePicture(
      params.buyerId,
      params.profilePicture,
    );
  }
}
