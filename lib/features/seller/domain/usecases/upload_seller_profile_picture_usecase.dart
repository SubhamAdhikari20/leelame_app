// lib/features/seller/domain/usecases/upload_seller_profile_picture_usecase.dart
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/core/usecases/app_usecase.dart';
import 'package:leelame/features/seller/data/repositories/seller_repository.dart';
import 'package:leelame/features/seller/domain/repositories/seller_repository.dart';

class UploadSellerProfilePictureUsecaseParams extends Equatable {
  final String sellerId;
  final File profilePicture;

  const UploadSellerProfilePictureUsecaseParams({
    required this.sellerId,
    required this.profilePicture,
  });

  @override
  List<Object?> get props => [profilePicture];
}

final uploadSellerProfilePictureUsecaseProvider =
    Provider<UploadSellerProfilePictureUsecase>((ref) {
      final sellerRepository = ref.read(sellerRepositoryProvider);
      return UploadSellerProfilePictureUsecase(
        sellerRepository: sellerRepository,
      );
    });

class UploadSellerProfilePictureUsecase
    implements
        UsecaseWithParams<String, UploadSellerProfilePictureUsecaseParams> {
  final ISellerRepository _sellerRepository;

  UploadSellerProfilePictureUsecase({
    required ISellerRepository sellerRepository,
  }) : _sellerRepository = sellerRepository;

  @override
  Future<Either<Failures, String>> call(
    UploadSellerProfilePictureUsecaseParams params,
  ) async {
    return await _sellerRepository.uploadSellerProfilePicture(
      params.sellerId,
      params.profilePicture,
    );
  }
}
