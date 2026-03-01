// lib/features/bid/data/datasources/remote/bid_remote_datasource.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/core/api/api_client.dart';
import 'package:leelame/core/api/api_endpoints.dart';
import 'package:leelame/core/services/storage/token_service.dart';
import 'package:leelame/features/bid/data/datasources/bid_datasource.dart';
import 'package:leelame/features/bid/data/models/bid_api_model.dart';

final bidRemoteDatasourceProvider = Provider<IBidRemoteDatasource>((ref) {
  final apiClient = ref.read(apiClientProvider);
  final tokenService = ref.read(tokenServiceProvider);
  return BidRemoteDatasource(apiClient: apiClient, tokenService: tokenService);
});

class BidRemoteDatasource implements IBidRemoteDatasource {
  final ApiClient _apiClient;
  final TokenService _tokenService;

  BidRemoteDatasource({
    required ApiClient apiClient,
    required TokenService tokenService,
  }) : _apiClient = apiClient,
       _tokenService = tokenService;

  @override
  Future<BidApiModel?> createBid(BidApiModel bidModel) async {
    final token = _tokenService.getToken();
    final response = await _apiClient.post(
      ApiEndpoints.createBid,
      data: bidModel.toJson(),
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
    final success = response.data["success"] as bool;
    final data = response.data["data"] as Map<String, dynamic>?;

    if (!success || data == null) {
      return null;
    }

    final newBid = BidApiModel.fromJson(data);
    return newBid;
  }

  @override
  Future<BidApiModel?> updateBid(BidApiModel bidModel) async {
    final token = _tokenService.getToken();
    final response = await _apiClient.post(
      ApiEndpoints.updateBid(bidModel.id!),
      data: bidModel.toJson(),
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
    final success = response.data["success"] as bool;
    final data = response.data["data"] as Map<String, dynamic>?;

    if (!success || data == null) {
      return null;
    }

    final updatedBid = BidApiModel.fromJson(data);
    return updatedBid;
  }

  @override
  Future<bool> deleteBid(String bidId) async {
    final token = _tokenService.getToken();
    final response = await _apiClient.post(
      ApiEndpoints.deleteBid(bidId),
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
    final success = response.data["success"] as bool;
    return success;
  }

  @override
  Future<BidApiModel?> getBidById(String bidId) async {
    final token = _tokenService.getToken();
    final response = await _apiClient.post(
      ApiEndpoints.bidById(bidId),
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
    final success = response.data["success"] as bool;
    final data = response.data["data"] as Map<String, dynamic>?;

    if (!success || data == null) {
      return null;
    }

    final updatedBid = BidApiModel.fromJson(data);
    return updatedBid;
  }

  @override
  Future<List<BidApiModel>> getAllBids() async {
    final response = await _apiClient.get(ApiEndpoints.getAllBids);
    final success = response.data["success"] as bool;
    final data = response.data["data"] as List<dynamic>?;

    if (!success || data == null) {
      return [];
    }

    final bids = BidApiModel.fromJsonList(data);
    return bids;
  }

  @override
  Future<List<BidApiModel>> getAllBidsByBuyerId(String buyerId) async {
    final response = await _apiClient.get(
      ApiEndpoints.getAllBidsByBuyerId(buyerId),
    );
    final success = response.data["success"] as bool;
    final data = response.data["data"] as List<dynamic>?;

    if (!success || data == null) {
      return [];
    }

    final bids = BidApiModel.fromJsonList(data);
    return bids;
  }

  @override
  Future<List<BidApiModel>> getAllBidsByProductId(String productId) async {
    final response = await _apiClient.get(
      ApiEndpoints.getAllBidsByProductId(productId),
    );
    final success = response.data["success"] as bool;
    final data = response.data["data"] as List<dynamic>?;

    if (!success || data == null) {
      return [];
    }

    final bids = BidApiModel.fromJsonList(data);
    return bids;
  }

  @override
  Future<List<BidApiModel>> getAllBidsBySellerId(String sellerId) async {
    final response = await _apiClient.get(
      ApiEndpoints.getAllBidsBySellerId(sellerId),
    );
    final success = response.data["success"] as bool;
    final data = response.data["data"] as List<dynamic>?;

    if (!success || data == null) {
      return [];
    }

    final bids = BidApiModel.fromJsonList(data);
    return bids;
  }
}
