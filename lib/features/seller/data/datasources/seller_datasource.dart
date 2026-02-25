// lib/features/seller/data/datasources/seller_datasource.dart
import 'dart:io';
import 'package:leelame/features/auth/data/models/user_hive_model.dart';
import 'package:leelame/features/seller/data/models/seller_api_model.dart';
import 'package:leelame/features/seller/data/models/seller_hive_model.dart';

abstract interface class ISellerLocalDatasource {
  Future<SellerHiveModel?> updateSeller(SellerHiveModel sellerHiveModel);
  Future<SellerHiveModel?> getSellerById(String sellerId);
  Future<UserHiveModel?> getBaseUserById(String userId);
  Future<List<SellerHiveModel>> getAllSellers();
}

abstract interface class ISellerRemoteDatasource {
  Future<SellerApiModel?> getCurrentSeller(String sellerId);
  Future<SellerApiModel?> updateSeller(SellerApiModel sellerApiModel);
  Future<String?> uploadSellerProfilePicture(
    String sellerId,
    File profilePicture,
  );
  Future<List<SellerApiModel>> getAllSellers();
}
