// lib/features/seller/presentation/states/seller_state.dart
import 'package:equatable/equatable.dart';
import 'package:leelame/features/seller/domain/entities/seller_entity.dart';

enum SellerStatus {
  initial,
  loading,
  created,
  updated,
  deleted,
  loaded,
  error,
  imageLoaded,
}

class SellerState extends Equatable {
  final SellerStatus sellerStatus;
  final List<SellerEntity> sellers;
  final SellerEntity? seller;
  final String? uploadedProfilePictureUrl;
  final String? errorMessage;

  const SellerState({
    this.sellerStatus = SellerStatus.initial,
    this.sellers = const [],
    this.seller,
    this.uploadedProfilePictureUrl,
    this.errorMessage,
  });

  // copywith function
  SellerState copyWith({
    SellerStatus? sellerStatus,
    List<SellerEntity>? sellers,
    SellerEntity? seller,
    String? uploadedProfilePictureUrl,
    String? errorMessage,
  }) {
    return SellerState(
      sellerStatus: sellerStatus ?? this.sellerStatus,
      sellers: sellers ?? this.sellers,
      seller: seller ?? this.seller,
      uploadedProfilePictureUrl:
          uploadedProfilePictureUrl ?? this.uploadedProfilePictureUrl,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    sellerStatus,
    sellers,
    seller,
    uploadedProfilePictureUrl,
    errorMessage,
  ];
}
