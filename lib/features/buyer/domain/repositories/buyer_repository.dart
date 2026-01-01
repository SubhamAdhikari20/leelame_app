// lib/features/buyer/domain/repositories/buyer_repository.dart
import 'package:dartz/dartz.dart';
import 'package:leelame/core/error/failures.dart';
import 'package:leelame/features/buyer/domain/entities/buyer_entity.dart';

abstract interface class IBuyerRepository {
  Future<Either<Failures, BuyerEntity?>> createBuyer(BuyerEntity buyerEntity);
  Future<Either<Failures, BuyerEntity?>> updateBuyer(BuyerEntity buyerEntity);
  Future<Either<Failures, BuyerEntity?>> getBuyerById(String buyerId);
  Future<Either<Failures, List<BuyerEntity>>> getAllBuyers();
  Future<Either<Failures, void>> deleteBuyer(String buyerId);
  Future<Either<Failures, void>> deleteAllBuyers();
}
