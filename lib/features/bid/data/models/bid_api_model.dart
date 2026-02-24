// lib/features/bid/data/models/bid_api_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leelame/features/bid/domain/entities/bid_entity.dart';

part "bid_api_model.g.dart";

@JsonSerializable()
class BidApiModel {
  @JsonKey(name: "_id")
  final String? id;
  final String? productId;
  final String? buyerId;
  final double bidAmount;

  BidApiModel({this.id, this.productId, this.buyerId, required this.bidAmount});

  // to Json
  Map<String, dynamic> toJson() {
    return _$BidApiModelToJson(this);
  }

  // From JSON
  factory BidApiModel.fromJson(Map<String, dynamic> json) {
    return _$BidApiModelFromJson(json);
  }

  // to JSON List
  static List<Map<String, dynamic>> toJsonList(List<BidApiModel> bidModels) {
    return bidModels.map((bidModel) => bidModel.toJson()).toList();
  }

  // from JSON List
  static List<BidApiModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => BidApiModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // to Entity
  BidEntity toEntity() {
    return BidEntity(
      bidId: id,
      productId: productId,
      buyerId: buyerId,
      bidAmount: bidAmount,
    );
  }

  // from Entity
  factory BidApiModel.fromEntity(BidEntity bidEntity) {
    return BidApiModel(
      id: bidEntity.bidId,
      productId: bidEntity.productId,
      buyerId: bidEntity.buyerId,
      bidAmount: bidEntity.bidAmount,
    );
  }

  // to Entity List
  static List<BidEntity> toEntityList(List<BidApiModel> bidModels) {
    return bidModels.map((bidModel) => bidModel.toEntity()).toList();
  }

  // from Entity List
  static List<BidApiModel> fromEntityList(List<BidEntity> bidEntities) {
    return bidEntities
        .map((bidEntity) => BidApiModel.fromEntity(bidEntity))
        .toList();
  }
}
