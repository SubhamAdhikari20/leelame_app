// lib/features/bid/presentation/models/bid_ui_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leelame/features/bid/domain/entities/bid_entity.dart';

@JsonSerializable()
class BidUiModel {
  @JsonKey(name: "_id")
  final String? id;
  final String? productId;
  final String? buyerId;
  final double bidAmount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BidUiModel({
    this.id,
    this.productId,
    this.buyerId,
    required this.bidAmount,
    this.createdAt,
    this.updatedAt,
  });

  // to Entity
  BidEntity toEntity() {
    return BidEntity(
      bidId: id,
      productId: productId,
      buyerId: buyerId,
      bidAmount: bidAmount,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // from Entity
  factory BidUiModel.fromEntity(BidEntity bidEntity) {
    return BidUiModel(
      id: bidEntity.bidId,
      productId: bidEntity.productId,
      buyerId: bidEntity.buyerId,
      bidAmount: bidEntity.bidAmount,
      createdAt: bidEntity.createdAt,
      updatedAt: bidEntity.updatedAt,
    );
  }

  // to Entity List
  static List<BidEntity> toEntityList(List<BidUiModel> bidModels) {
    return bidModels.map((bidModel) => bidModel.toEntity()).toList();
  }

  // from Entity List
  static List<BidUiModel> fromEntityList(List<BidEntity> bidEntities) {
    return bidEntities
        .map((bidEntity) => BidUiModel.fromEntity(bidEntity))
        .toList();
  }

  BidUiModel copyWith({
    String? id,
    String? productId,
    String? buyerId,
    double? bidAmount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BidUiModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      buyerId: buyerId ?? this.buyerId,
      bidAmount: bidAmount ?? this.bidAmount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
