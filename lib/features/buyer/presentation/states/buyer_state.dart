// lib/features/buyer/presentation/states/buyer_state.dart
import 'package:equatable/equatable.dart';
import 'package:leelame/features/buyer/domain/entities/buyer_entity.dart';

enum BuyerStatus { initial, loading, created, updated, deleted, loaded, error, imageLoaded }

class BuyerState extends Equatable {
  final BuyerStatus buyerStatus;
  final List<BuyerEntity> buyers;
  final BuyerEntity? buyer;
  final String? uploadedProfilePictureUrl;
  final String? errorMessage;

  const BuyerState({
    this.buyerStatus = BuyerStatus.initial,
    this.buyers = const [],
    this.buyer,
    this.uploadedProfilePictureUrl,
    this.errorMessage,
  });

  // copywith function
  BuyerState copyWith({
    BuyerStatus? buyerStatus,
    List<BuyerEntity>? buyers,
    BuyerEntity? buyer,
    String? uploadedProfilePictureUrl,
    String? errorMessage,
  }) {
    return BuyerState(
      buyerStatus: buyerStatus ?? this.buyerStatus,
      buyers: buyers ?? this.buyers,
      buyer: buyer ?? this.buyer,
      uploadedProfilePictureUrl:
          uploadedProfilePictureUrl ?? this.uploadedProfilePictureUrl,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    buyerStatus,
    buyers,
    buyer,
    uploadedProfilePictureUrl,
    errorMessage,
  ];
}
