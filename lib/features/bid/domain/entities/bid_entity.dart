// lib/features/bid/domain/entities/bid_entity.dart
import 'package:equatable/equatable.dart';

class BidEntity extends Equatable {
  final String? bidId;
  final String? productId;
  final String? buyerId;
  final double bidAmount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BidEntity({
    this.bidId,
    required this.productId,
    required this.buyerId,
    required this.bidAmount,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    bidId,
    productId,
    buyerId,
    bidAmount,
    createdAt,
    updatedAt,
  ];

  BidEntity copyWith({
    String? bidId,
    String? productId,
    String? buyerId,
    double? bidAmount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BidEntity(
      bidId: bidId ?? this.bidId,
      productId: productId ?? this.productId,
      buyerId: buyerId ?? this.buyerId,
      bidAmount: bidAmount ?? this.bidAmount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
