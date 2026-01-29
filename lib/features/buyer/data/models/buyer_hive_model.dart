// lib/features/buyer/data/models/buyer_hive_model.dart
import 'package:hive/hive.dart';
import 'package:leelame/core/constants/hive_table_constant.dart';
import 'package:leelame/features/auth/domain/entities/user_entity.dart';
import 'package:leelame/features/buyer/domain/entities/buyer_entity.dart';
import 'package:uuid/uuid.dart';

part "buyer_hive_model.g.dart";

@HiveType(typeId: HiveTableConstant.buyersTypeId)
class BuyerHiveModel extends HiveObject {
  @HiveField(0)
  final String? buyerId;

  @HiveField(1)
  final String fullName;

  @HiveField(2)
  final String? username;

  @HiveField(3)
  final String? phoneNumber;

  @HiveField(4)
  final String? password;

  @HiveField(5)
  final String? profilePictureUrl;

  @HiveField(6)
  final String? bio;

  @HiveField(7)
  final bool? termsAccepted;

  @HiveField(8)
  final String? baseUserId;

  BuyerHiveModel({
    String? buyerId,
    required this.fullName,
    this.username,
    this.phoneNumber,
    this.password,
    this.profilePictureUrl,
    this.bio,
    this.termsAccepted,
    String? baseUserId,
  }) : buyerId = buyerId ?? Uuid().v4(),
       baseUserId = baseUserId ?? Uuid().v4();

  // Convert Model to Buyer Entity
  BuyerEntity toEntity({UserEntity? userEntity}) {
    return BuyerEntity(
      buyerId: buyerId,
      fullName: fullName,
      username: username,
      phoneNumber: phoneNumber,
      password: password,
      profilePictureUrl: profilePictureUrl,
      bio: bio,
      termsAccepted: termsAccepted,
      baseUserId: baseUserId,
      userEntity: userEntity,
    );
  }

  // Convert Buyer Entity to Model
  factory BuyerHiveModel.fromEntity(BuyerEntity buyerEntity) {
    return BuyerHiveModel(
      buyerId: buyerEntity.buyerId,
      fullName: buyerEntity.fullName,
      username: buyerEntity.username,
      phoneNumber: buyerEntity.phoneNumber,
      password: buyerEntity.password,
      profilePictureUrl: buyerEntity.profilePictureUrl,
      bio: buyerEntity.bio,
      termsAccepted: buyerEntity.termsAccepted,
      baseUserId: buyerEntity.baseUserId,
    );
  }

  // Convert List of Models to List of Buyer Entities
  static List<BuyerEntity> toEntityList(List<BuyerHiveModel> buyerModels) {
    return buyerModels.map((buyerModel) => buyerModel.toEntity()).toList();
  }

  // copyWith helper to create updated instances (used before saving to Hive)
  BuyerHiveModel copyWith({
    String? buyerId,
    String? fullName,
    String? username,
    String? phoneNumber,
    String? password,
    String? profilePictureUrl,
    String? bio,
    bool? termsAccepted,
    String? baseUserId,
  }) {
    return BuyerHiveModel(
      buyerId: buyerId ?? this.buyerId,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      password: password ?? this.password,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      bio: bio ?? this.bio,
      termsAccepted: termsAccepted ?? this.termsAccepted,
      baseUserId: baseUserId ?? this.baseUserId,
    );
  }
}
