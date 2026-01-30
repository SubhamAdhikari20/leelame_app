// lib/features/buyer/presentation/models/buyer_ui_model.dart
import 'package:leelame/features/auth/presentation/models/user_ui_model.dart';
import 'package:leelame/features/buyer/domain/entities/buyer_entity.dart';

class BuyerUiModel {
  final String? buyerId;
  final String fullName;
  final String? username;
  final String? phoneNumber;
  final String? password;
  final String? profilePictureUrl;
  final String? bio;
  final bool? termsAccepted;

  // Reference from base user
  final String? baseUserId;
  final UserUiModel? userUiModel;

  const BuyerUiModel({
    this.buyerId,
    required this.fullName,
    this.username,
    this.phoneNumber,
    this.password,
    this.profilePictureUrl,
    this.bio,
    this.termsAccepted,
    this.baseUserId,
    this.userUiModel,
  });

  // to Entity
  BuyerEntity toEntity() {
    return BuyerEntity(
      buyerId: buyerId,
      fullName: fullName,
      username: username,
      phoneNumber: phoneNumber,
      profilePictureUrl: profilePictureUrl,
      bio: bio,
      termsAccepted: termsAccepted,
      baseUserId: baseUserId,
      userEntity: userUiModel?.toEntity(),
    );
  }

  // from Entity
  factory BuyerUiModel.fromEntity(BuyerEntity buyerEntity) {
    return BuyerUiModel(
      buyerId: buyerEntity.buyerId,
      fullName: buyerEntity.fullName,
      username: buyerEntity.username,
      phoneNumber: buyerEntity.phoneNumber,
      password: buyerEntity.password,
      profilePictureUrl: buyerEntity.profilePictureUrl,
      bio: buyerEntity.bio,
      termsAccepted: buyerEntity.termsAccepted,
      baseUserId: buyerEntity.baseUserId,
      userUiModel: buyerEntity.userEntity != null
          ? UserUiModel.fromEntity(buyerEntity.userEntity!)
          : null,
    );
  }

  // to Entity List
  static List<BuyerEntity> toEntityList(List<BuyerUiModel> buyerUiModels) {
    return buyerUiModels.map((buyerModel) => buyerModel.toEntity()).toList();
  }

  // from Entity List
  static List<BuyerUiModel> fromEntityList(List<BuyerEntity> buyerEntities) {
    return buyerEntities
        .map((buyerEntity) => BuyerUiModel.fromEntity(buyerEntity))
        .toList();
  }

  BuyerUiModel copyWith({
    String? buyerId,
    String? fullName,
    String? username,
    String? phoneNumber,
    String? password,
    String? profilePictureUrl,
    String? bio,
    bool? termsAccepted,
    String? baseUserId,
    UserUiModel? userUiModel,
  }) {
    return BuyerUiModel(
      buyerId: buyerId ?? this.buyerId,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      password: password ?? this.password,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      bio: bio ?? this.bio,
      termsAccepted: termsAccepted ?? this.termsAccepted,
      baseUserId: baseUserId ?? this.baseUserId,
      userUiModel: userUiModel ?? this.userUiModel,
    );
  }
}
