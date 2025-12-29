// lib/features/auth/data/models/user_hive_model.dart
import 'package:hive/hive.dart';
import 'package:leelame/core/constants/hive_table_constant.dart';
import 'package:leelame/features/auth/domain/entities/user_entity.dart';
import 'package:uuid/uuid.dart';

@HiveType(typeId: HiveTableConstant.usersTypeId)
class UserHiveModel {
  @HiveField(0)
  final String? userId;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String role;

  @HiveField(3)
  final bool isVerified;

  UserHiveModel({
    String? userId,
    required this.email,
    required this.role,
    required this.isVerified,
  }) : userId = userId ?? Uuid().v4();

  // Convert Model to User Entity
  UserEntity toEntity() {
    return UserEntity(
      userId: userId,
      email: email,
      role: role,
      isVerified: isVerified,
    );
  }

  // Convert User Entity to Model
  factory UserHiveModel.fromEntity(UserEntity userEntity) {
    return UserHiveModel(
      userId: userEntity.userId,
      email: userEntity.email,
      role: userEntity.role,
      isVerified: userEntity.isVerified,
    );
  }

  // Convert List of Models to List of User Entities
  static List<UserEntity> toEntityList(List<UserHiveModel> userModels) {
    return userModels.map((userModel) => userModel.toEntity()).toList();
  }
}
