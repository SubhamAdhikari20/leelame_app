// lib/features/bid/data/datasources/local/bid_local_datasource.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/services/hive/hive_service.dart';
import 'package:leelame/features/bid/data/datasources/bid_datasource.dart';
import 'package:leelame/features/bid/data/models/bid_hive_model.dart';
import 'package:leelame/features/product/data/models/product_hive_model.dart';

final bidLocalDatasourceProvider = Provider<IBidLocalDatasource>((ref) {
  final hiveService = ref.read(hiveServiceProvider);
  return BidLocalDatasource(hiveService: hiveService);
});

class BidLocalDatasource implements IBidLocalDatasource {
  final HiveService _hiveService;

  BidLocalDatasource({required HiveService hiveService})
    : _hiveService = hiveService;

  @override
  Future<BidHiveModel?> createBid(BidHiveModel bidModel) async {
    final result = await _hiveService.createBid(bidModel);
    return Future.value(result);
  }

  @override
  Future<BidHiveModel?> updateBid(BidHiveModel bidModel) async {
    final result = await _hiveService.updateBid(bidModel);
    return Future.value(result);
  }

  @override
  Future<bool> deleteBid(String bidId) async {
    final result = await _hiveService.deleteBid(bidId);
    return Future.value(result);
  }

  @override
  Future<BidHiveModel?> getBidById(String bidId) async {
    final result = await _hiveService.getBidById(bidId);
    return Future.value(result);
  }

  @override
  Future<List<BidHiveModel>> getAllBids() async {
    final result = await _hiveService.getAllBids();
    return Future.value(result);
  }

  @override
  Future<List<BidHiveModel>> getAllBidsByBuyerId(String buyerId) async {
    final result = await _hiveService.getAllBidsByBuyerId(buyerId);
    return Future.value(result);
  }

  @override
  Future<List<BidHiveModel>> getAllBidsByProductId(String productId) async {
    final result = await _hiveService.getAllBidsByProductId(productId);
    return Future.value(result);
  }

  @override
  Future<List<BidHiveModel>> getAllBidsBySellerId(String sellerId) async {
    final result = await _hiveService.getAllBidsBySellerId(sellerId);
    return Future.value(result);
  }

  @override
  Future<ProductHiveModel?> getProductById(String productId) async {
    final result = await _hiveService.getProductById(productId);
    return Future.value(result);
  }
}
