// lib/features/buyer/domain/repositories/buyer_repository.dart
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/features/buyer/domain/entities/buyer_entity.dart';

abstract interface class IBuyerRepository {
  Future<Either<Failures, BuyerEntity>> getCurrentBuyer(String buyerId);
  Future<Either<Failures, BuyerEntity>> updateBuyer(BuyerEntity buyerEntity);
  Future<Either<Failures, String>> uploadBuyerProfilePicture(
    String buyerId,
    File profilePicture,
  );
}
