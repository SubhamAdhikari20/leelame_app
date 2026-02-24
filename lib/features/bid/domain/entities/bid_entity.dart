// lib/features/bid/domain/entities/bid_entity.dart
import 'package:equatable/equatable.dart';

class BidEntity extends Equatable {
  final String? bidId;
  final String? productId;
  final String? buyerId;
  final double bidAmount;

  const BidEntity({
    this.bidId,
    required this.productId,
    required this.buyerId,
    required this.bidAmount,
  });

  @override
  List<Object?> get props => [bidId, productId, buyerId, bidAmount];

  BidEntity copyWith({
    String? bidId,
    String? productId,
    String? buyerId,
    double? bidAmount,
  }) {
    return BidEntity(
      bidId: bidId ?? this.bidId,
      productId: productId ?? this.productId,
      buyerId: buyerId ?? this.buyerId,
      bidAmount: bidAmount ?? this.bidAmount,
    );
  }
}
