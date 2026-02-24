// lib/features/bid/data/models/bid_hive_model.dart
import 'package:hive_ce/hive.dart';
import 'package:leelame/core/constants/hive_table_constant.dart';
import 'package:leelame/features/bid/domain/entities/bid_entity.dart';
import 'package:uuid/uuid.dart';

part "bid_hive_model.g.dart";

@HiveType(typeId: HiveTableConstant.bidsTypeId)
class BidHiveModel extends HiveObject {
  @HiveField(0)
  final String? bidId;

  @HiveField(1)
  final String? productId;

  @HiveField(2)
  final String? buyerId;

  @HiveField(3)
  final double bidAmount;

  BidHiveModel({
    String? bidId,
    required this.productId,
    required this.buyerId,
    required this.bidAmount,
  }) : bidId = bidId ?? Uuid().v4();

  // Convert Model to Bid Entity
  BidEntity toEntity() {
    return BidEntity(
      bidId: bidId,
      productId: productId,
      buyerId: buyerId,
      bidAmount: bidAmount,
    );
  }

  // Convert Bid Entity to Model
  factory BidHiveModel.fromEntity(BidEntity bidEntity) {
    return BidHiveModel(
      bidId: bidEntity.bidId,
      productId: bidEntity.productId,
      buyerId: bidEntity.buyerId,
      bidAmount: bidEntity.bidAmount,
    );
  }

  // Convert List of Models to List of Bid Entities
  static List<BidEntity> toEntityList(List<BidHiveModel> bidModels) {
    return bidModels.map((bidModel) => bidModel.toEntity()).toList();
  }

  BidHiveModel copyWith({
    String? bidId,
    String? productId,
    String? buyerId,
    double? bidAmount,
  }) {
    return BidHiveModel(
      bidId: bidId ?? this.bidId,
      productId: productId ?? this.productId,
      buyerId: buyerId ?? this.buyerId,
      bidAmount: bidAmount ?? this.bidAmount,
    );
  }
}
