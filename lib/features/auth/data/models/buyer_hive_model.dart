// lib/features/auth/data/models/buyer_hive_model.dart
import 'package:hive/hive.dart';
import 'package:leelame/core/constants/hive_table_constant.dart';
import 'package:leelame/features/auth/domain/entities/buyer_entity.dart';
import 'package:uuid/uuid.dart';

@HiveType(typeId: HiveTableConstant.buyersTypeId)
class BuyerHiveModel {
  @HiveField(0)
  final String? buyerId;

  @HiveField(1)
  final String fullName;

  @HiveField(2)
  final String? username;

  @HiveField(3)
  final String? mobileNumber;

  @HiveField(4)
  final String? password;

  @HiveField(5)
  final String? profilePictureUrl;

  @HiveField(6)
  final String? bio;

  BuyerHiveModel({
    String? buyerId,
    required this.fullName,
    String? username,
    String? mobileNumber,
    String? password,
    String? profilePictureUrl,
    String? bio,
  }) : buyerId = buyerId ?? Uuid().v4(),
       username = username ?? "",
       mobileNumber = mobileNumber ?? "",
       password = password ?? "",
       profilePictureUrl = profilePictureUrl ?? "",
       bio = bio ?? "";

  // Convert Model to Buyer Entity
  BuyerEntity toEntity() {
    return BuyerEntity(
      buyerId: buyerId,
      fullName: fullName,
      username: username,
      mobileNumber: mobileNumber,
      password: password,
      profilePictureUrl: profilePictureUrl,
      bio: bio,
    );
  }

  // Convert Buyer Entity to Model
  factory BuyerHiveModel.fromEntity(BuyerEntity buyerEntity) {
    return BuyerHiveModel(
      buyerId: buyerEntity.buyerId,
      fullName: buyerEntity.fullName,
      username: buyerEntity.username,
      mobileNumber: buyerEntity.mobileNumber,
      password: buyerEntity.password,
      profilePictureUrl: buyerEntity.profilePictureUrl,
      bio: buyerEntity.bio,
    );
  }

  // Convert List of Models to List of Buyer Entities
  static List<BuyerEntity> toEntityList(List<BuyerHiveModel> buyerModels) {
    return buyerModels.map((buyerModel) => buyerModel.toEntity()).toList();
  }
}
