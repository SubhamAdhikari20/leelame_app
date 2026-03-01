// lib/features/buyer/data/datasources/buyer_datasource.dart
import 'dart:io';
import 'package:leelame/features/auth/data/models/user_hive_model.dart';
import 'package:leelame/features/buyer/data/models/buyer_api_model.dart';
import 'package:leelame/features/buyer/data/models/buyer_hive_model.dart';

abstract interface class IBuyerLocalDatasource {
  Future<BuyerHiveModel?> getCurrentBuyer(String buyerId);
  Future<BuyerHiveModel?> getBuyerById(String buyerId);
  Future<BuyerHiveModel?> updateBuyer(BuyerHiveModel buyerHiveModel);
  Future<UserHiveModel?> getBaseUserById(String userId);
  Future<List<BuyerHiveModel>> getAllBuyers();
}

abstract interface class IBuyerRemoteDatasource {
  Future<BuyerApiModel?> getCurrentBuyer(String buyerId);
  Future<BuyerApiModel?> getBuyerById(String buyerId);
  Future<BuyerApiModel?> updateBuyer(BuyerApiModel buyerApiModel);
  Future<String?> uploadBuyerProfilePicture(
    String buyerId,
    File profilePicture,
  );

  Future<List<BuyerApiModel>> getAllBuyers();
}
