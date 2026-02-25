// lib/features/seller/data/datasources/local/seller_local_datasource.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/services/hive/hive_service.dart';
import 'package:leelame/features/auth/data/models/user_hive_model.dart';
import 'package:leelame/features/seller/data/datasources/seller_datasource.dart';
import 'package:leelame/features/seller/data/models/seller_hive_model.dart';

final sellerLocalDatasourceProvider = Provider<ISellerLocalDatasource>((ref) {
  final hiveService = ref.read(hiveServiceProvider);
  return SellerLocalDatasource(hiveService: hiveService);
});

class SellerLocalDatasource implements ISellerLocalDatasource {
  final HiveService _hiveService;

  SellerLocalDatasource({required HiveService hiveService})
    : _hiveService = hiveService;

  @override
  Future<SellerHiveModel?> getSellerById(String sellerId) async {
    final result = await _hiveService.getSellerById(sellerId);
    return Future.value(result);
  }

  @override
  Future<UserHiveModel?> getBaseUserById(String userId) async {
    final result = await _hiveService.getUserById(userId);
    return Future.value(result);
  }

  @override
  Future<SellerHiveModel?> updateSeller(SellerHiveModel sellerHiveModel) async {
    final result = await _hiveService.updateSeller(sellerHiveModel);
    return Future.value(result);
  }

  @override
  Future<List<SellerHiveModel>> getAllSellers() async {
    final result = await _hiveService.getAllSellers();
    return Future.value(result);
  }
}
