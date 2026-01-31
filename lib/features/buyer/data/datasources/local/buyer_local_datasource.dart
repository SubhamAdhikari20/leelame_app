// lib/features/buyer/data/datasources/local/buyer_local_datasource.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/services/hive/hive_service.dart';
import 'package:leelame/features/auth/data/models/user_hive_model.dart';
import 'package:leelame/features/buyer/data/datasources/buyer_datasource.dart';
import 'package:leelame/features/buyer/data/models/buyer_hive_model.dart';

final buyerLocalDatasourceProvider = Provider<IBuyerLocalDatasource>((ref) {
  final hiveService = ref.read(hiveServiceProvider);
  return BuyerLocalDatasource(hiveService: hiveService);
});

class BuyerLocalDatasource implements IBuyerLocalDatasource {
  final HiveService _hiveService;

  BuyerLocalDatasource({required HiveService hiveService})
    : _hiveService = hiveService;

  @override
  Future<BuyerHiveModel?> getBuyerById(String buyerId) async {
    final result = await _hiveService.getBuyerById(buyerId);
    return Future.value(result);
  }

  @override
  Future<UserHiveModel?> getBaseUserById(String userId) async {
    final result = await _hiveService.getUserById(userId);
    return Future.value(result);
  }

  @override
  Future<BuyerHiveModel?> updateBuyer(BuyerHiveModel buyerHiveModel) async {
    final result = await _hiveService.updateBuyer(buyerHiveModel);
    return Future.value(result);
  }
}
