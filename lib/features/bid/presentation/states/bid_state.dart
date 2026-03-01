// lib/features/bid/presentation/states/bid_state.dart
import 'package:equatable/equatable.dart';
import 'package:leelame/features/bid/domain/entities/bid_entity.dart';

enum BidStatus { initial, loading, loaded, error, created, updated, deleted }

class BidState extends Equatable {
  final BidStatus bidStatus;
  final List<BidEntity> bids;
  final BidEntity? selectedBid;
  final String? errorMessage;

  const BidState({
    this.bidStatus = BidStatus.initial,
    this.bids = const [],
    this.selectedBid,
    this.errorMessage,
  });

  BidState copyWith({
    BidStatus? bidStatus,
    List<BidEntity>? bids,
    BidEntity? selectedBid,
    String? errorMessage,
  }) {
    return BidState(
      bidStatus: bidStatus ?? this.bidStatus,
      bids: bids ?? this.bids,
      selectedBid: selectedBid ?? this.selectedBid,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [bidStatus, bids, selectedBid, errorMessage];
}
