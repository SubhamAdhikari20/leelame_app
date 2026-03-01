// lib/features/bid/data/datasources/bid_datasource.dart
import 'package:leelame/features/bid/data/models/bid_api_model.dart';
import 'package:leelame/features/bid/data/models/bid_hive_model.dart';
import 'package:leelame/features/product/data/models/product_hive_model.dart';

abstract interface class IBidLocalDatasource {
  Future<BidHiveModel?> createBid(BidHiveModel bidModel);
  Future<BidHiveModel?> updateBid(BidHiveModel bidModel);
  Future<BidHiveModel?> getBidById(String bidId);
  Future<bool> deleteBid(String bidId);
  Future<List<BidHiveModel>> getAllBids();
  Future<List<BidHiveModel>> getAllBidsByProductId(String productId);
  Future<List<BidHiveModel>> getAllBidsByBuyerId(String buyerId);
  Future<List<BidHiveModel>> getAllBidsBySellerId(String sellerId);
  Future<ProductHiveModel?> getProductById(String productId);
}

abstract interface class IBidRemoteDatasource {
  Future<BidApiModel?> createBid(BidApiModel bidModel);
  Future<BidApiModel?> updateBid(BidApiModel bidModel);
  Future<BidApiModel?> getBidById(String bidId);
  Future<bool> deleteBid(String bidId);
  Future<List<BidApiModel>> getAllBids();
  Future<List<BidApiModel>> getAllBidsByProductId(String productId);
  Future<List<BidApiModel>> getAllBidsByBuyerId(String buyerId);
  Future<List<BidApiModel>> getAllBidsBySellerId(String sellerId);
}
