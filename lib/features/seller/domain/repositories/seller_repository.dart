// lib/features/seller/domain/repositories/seller_repository.dart
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/features/seller/domain/entities/seller_entity.dart';

abstract interface class ISellerRepository {
  Future<Either<Failures, SellerEntity>> getCurrentSeller(String sellerId);
  Future<Either<Failures, SellerEntity>> getSellerById(String sellerId);
  Future<Either<Failures, SellerEntity>> updateSeller(
    SellerEntity sellerEntity,
  );
  Future<Either<Failures, String>> uploadSellerProfilePicture(
    String sellerId,
    File profilePicture,
  );
  Future<Either<Failures, List<SellerEntity>>> getAllSellers();
}
