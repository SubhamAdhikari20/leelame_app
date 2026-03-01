// lib/features/bid/presentation/view_models/bid_view_model.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leelame/features/bid/domain/usecases/create_bid_usecase.dart';
import 'package:leelame/features/bid/domain/usecases/delete_bid_usecase.dart';
import 'package:leelame/features/bid/domain/usecases/get_all_bids_by_buyer_id_usecase.dart';
import 'package:leelame/features/bid/domain/usecases/get_all_bids_by_product_id_usecase.dart';
import 'package:leelame/features/bid/domain/usecases/get_all_bids_by_seller_id_usecase.dart';
import 'package:leelame/features/bid/domain/usecases/get_all_bids_usecase.dart';
import 'package:leelame/features/bid/domain/usecases/get_bid_by_id_usecase.dart';
import 'package:leelame/features/bid/domain/usecases/update_bid_usecase.dart';
import 'package:leelame/features/bid/presentation/states/bid_state.dart';

final bidViewModelProvider = NotifierProvider<BidViewModel, BidState>(() {
  return BidViewModel();
});

class BidViewModel extends Notifier<BidState> {
  late final CreateBidUsecase _createBidUsecase;
  late final UpdateBidUsecase _updateBidUsecase;
  late final DeleteBidUsecase _deleteBidUsecase;
  late final GetAllBidsUsecase _getAllBidsUsecase;
  late final GetAllBidsByBuyerIdUsecase _getAllBidsByBuyerIdUsecase;
  late final GetAllBidsBySellerIdUsecase _getAllBidsBySellerIdUsecase;
  late final GetAllBidsByProductIdUsecase _getAllBidsByProductIdUsecase;
  late final GetBidByIdUsecase _getBidByIdUsecase;

  @override
  BidState build() {
    _createBidUsecase = ref.read(createBidUsecaseProvider);
    _updateBidUsecase = ref.read(updateBidUsecaseProvider);
    _deleteBidUsecase = ref.read(deleteBidUsecaseProvider);
    _getAllBidsUsecase = ref.read(getAllBidsUsecaseProvider);
    _getAllBidsByBuyerIdUsecase = ref.read(getAllBidsByBuyerIdUsecaseProvider);
    _getAllBidsBySellerIdUsecase = ref.read(
      getAllBidsBySellerIdUsecaseProvider,
    );
    _getAllBidsByProductIdUsecase = ref.read(
      getAllBidsByProductIdUsecaseProvider,
    );
    _getBidByIdUsecase = ref.read(getBidByIdUsecaseProvider);
    return const BidState();
  }

  Future<void> createBid({
    required String productId,
    required String buyerId,
    required double bidAmount,
  }) async {
    state = state.copyWith(bidStatus: BidStatus.loading);
    final result = await _createBidUsecase(
      CreateBidUsecaseParams(
        productId: productId,
        buyerId: buyerId,
        bidAmount: bidAmount,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        bidStatus: BidStatus.error,
        errorMessage: failure.message,
      ),
      (bid) => state = state.copyWith(
        bidStatus: BidStatus.created,
        selectedBid: bid,
      ),
    );
  }

  Future<void> updateBid({
    required String bidId,
    required String productId,
    required String buyerId,
    required double bidAmount,
  }) async {
    state = state.copyWith(bidStatus: BidStatus.loading);
    final result = await _updateBidUsecase(
      UpdateBidUsecaseParams(
        bidId: bidId,
        productId: productId,
        buyerId: buyerId,
        bidAmount: bidAmount,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        bidStatus: BidStatus.error,
        errorMessage: failure.message,
      ),
      (bid) => state = state.copyWith(
        bidStatus: BidStatus.updated,
        selectedBid: bid,
      ),
    );
  }

  Future<void> deleteBid(String bidId) async {
    state = state.copyWith(bidStatus: BidStatus.loading);
    final result = await _deleteBidUsecase(
      DeleteBidUsecaseParams(bidId: bidId),
    );

    result.fold(
      (failure) => state = state.copyWith(
        bidStatus: BidStatus.error,
        errorMessage: failure.message,
      ),
      (success) => state = state.copyWith(bidStatus: BidStatus.deleted),
    );
  }

  Future<void> getAllBids() async {
    state = state.copyWith(bidStatus: BidStatus.loading);
    final result = await _getAllBidsUsecase();

    result.fold(
      (failure) => state = state.copyWith(
        bidStatus: BidStatus.error,
        errorMessage: failure.message,
      ),
      (bids) => state = state.copyWith(bidStatus: BidStatus.loaded, bids: bids),
    );
  }

  Future<void> getAllBidsByBuyerId(String buyerId) async {
    state = state.copyWith(bidStatus: BidStatus.loading);
    final result = await _getAllBidsByBuyerIdUsecase(
      GetAllBidsByBuyerIdUsecaseParams(buyerId: buyerId),
    );

    result.fold(
      (failure) => state = state.copyWith(
        bidStatus: BidStatus.error,
        errorMessage: failure.message,
      ),
      (bids) => state = state.copyWith(bidStatus: BidStatus.loaded, bids: bids),
    );
  }

  Future<void> getAllBidsBySellerId(String sellerId) async {
    state = state.copyWith(bidStatus: BidStatus.loading);
    final result = await _getAllBidsBySellerIdUsecase(
      GetAllBidsBySellerIdUsecaseParams(sellerId: sellerId),
    );

    result.fold(
      (failure) => state = state.copyWith(
        bidStatus: BidStatus.error,
        errorMessage: failure.message,
      ),
      (bids) => state = state.copyWith(bidStatus: BidStatus.loaded, bids: bids),
    );
  }

  Future<void> getAllBidsByProductId(String productId) async {
    state = state.copyWith(bidStatus: BidStatus.loading);
    final result = await _getAllBidsByProductIdUsecase(
      GetAllBidsByProductIdUsecaseParams(productId: productId),
    );

    result.fold(
      (failure) => state = state.copyWith(
        bidStatus: BidStatus.error,
        errorMessage: failure.message,
      ),
      (bids) => state = state.copyWith(bidStatus: BidStatus.loaded, bids: bids),
    );
  }

  Future<void> getBidById(String bidId) async {
    state = state.copyWith(bidStatus: BidStatus.loading);

    final result = await _getBidByIdUsecase(
      GetBidByIdUsecaseParams(bidId: bidId),
    );

    result.fold(
      (failure) => state = state.copyWith(
        bidStatus: BidStatus.error,
        errorMessage: failure.message,
      ),
      (bid) =>
          state = state.copyWith(bidStatus: BidStatus.loaded, selectedBid: bid),
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void clearBidList() {
    state = state.copyWith(bids: []);
  }

  void clearBidStatus() {
    state = state.copyWith(bidStatus: BidStatus.initial);
  }

  void clearSelectedBid() {
    state = state.copyWith(selectedBid: null);
  }
}
