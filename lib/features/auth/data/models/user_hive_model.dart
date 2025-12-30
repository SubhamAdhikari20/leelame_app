// lib/features/auth/data/models/user_hive_model.dart
import 'package:hive/hive.dart';
import 'package:leelame/core/constants/hive_table_constant.dart';
import 'package:leelame/features/auth/domain/entities/user_entity.dart';
import 'package:uuid/uuid.dart';

part "user_hive_model.g.dart";

@HiveType(typeId: HiveTableConstant.usersTypeId)
class UserHiveModel {
  @HiveField(0)
  final String? id;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String role;

  @HiveField(3)
  final bool isVerified;

  @HiveField(4)
  final bool isPermanentlyBanned;

  @HiveField(5)
  final String? banReason;

  @HiveField(6)
  final DateTime? bannedAt;

  @HiveField(7)
  final DateTime? bannedFrom;

  @HiveField(8)
  final DateTime? bannedTo;

  @HiveField(9)
  final String? buyerProfileId;

  @HiveField(10)
  final String? sellerProfileId;

  UserHiveModel({
    String? id,
    required this.email,
    required this.role,
    required this.isVerified,
    required this.isPermanentlyBanned,
    this.banReason,
    this.bannedAt,
    this.bannedFrom,
    this.bannedTo,
    this.buyerProfileId,
    this.sellerProfileId,
  }) : id = id ?? Uuid().v4();

  // Convert Model to User Entity
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      role: role,
      isVerified: isVerified,
      isPermanentlyBanned: isPermanentlyBanned,
      banReason: banReason,
      bannedAt: bannedAt,
      bannedFrom: bannedFrom,
      bannedTo: bannedTo,
      buyerId: buyerProfileId,
      sellerId: sellerProfileId,
    );
  }

  // Convert User Entity to Model
  factory UserHiveModel.fromEntity(UserEntity userEntity) {
    return UserHiveModel(
      id: userEntity.id,
      email: userEntity.email,
      role: userEntity.role,
      isVerified: userEntity.isVerified,
      isPermanentlyBanned: userEntity.isPermanentlyBanned,
      banReason: userEntity.banReason,
      bannedAt: userEntity.bannedAt,
      bannedFrom: userEntity.bannedFrom,
      bannedTo: userEntity.bannedTo,
      buyerProfileId: userEntity.buyerId,
      sellerProfileId: userEntity.sellerId,
    );
  }

  // Convert List of Models to List of User Entities
  static List<UserEntity> toEntityList(List<UserHiveModel> userModels) {
    return userModels.map((userModel) => userModel.toEntity()).toList();
  }
}
