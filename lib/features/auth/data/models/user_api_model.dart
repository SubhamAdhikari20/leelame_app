// lib/features/auth/data/models/user_api_model.dart
import 'package:leelame/features/auth/domain/entities/user_entity.dart';

class UserApiModel {
  final String? id;
  final String email;
  final String role;
  final bool isVerified;
  final bool isPermanentlyBanned;
  final String? banReason;
  final DateTime? bannedAt;
  final DateTime? bannedFrom;
  final DateTime? bannedTo;

  UserApiModel({
    this.id,
    required this.email,
    required this.role,
    required this.isVerified,
    required this.isPermanentlyBanned,
    this.banReason,
    this.bannedAt,
    this.bannedFrom,
    this.bannedTo,
  });

  // to JSON
  Map<String, dynamic> toJson() {
    return {
      "email": email,
      "role": role,
      "isVerified": isVerified,
      "isPermanentlyBanned": isPermanentlyBanned,
      "banReason": banReason,
      "bannedAt": bannedAt?.toIso8601String(),
      "bannedFrom": bannedFrom?.toIso8601String(),
      "bannedTo": bannedTo?.toIso8601String(),
    };
  }

  // From JSON
  factory UserApiModel.fromJson(Map<String, dynamic> json) {
    return UserApiModel(
      id: json["_id"] as String,
      email: json["email"] as String,
      role: json["role"] as String,
      isVerified: json["isVerified"] as bool,
      isPermanentlyBanned: json["isPermanentlyBanned"] as bool,
      banReason: json["banReason"] as String?,
      bannedAt: json["bannedAt"] != null
          ? DateTime.parse(json["bannedAt"])
          : null,
      bannedFrom: json["bannedFrom"] != null
          ? DateTime.parse(json["bannedFrom"])
          : null,
      bannedTo: json["bannedTo"] != null
          ? DateTime.parse(json["bannedTo"])
          : null,
    );
  }

  // to JSON List
  static List<Map<String, dynamic>> toJsonList(List<UserApiModel> userModels) {
    return userModels.map((userModel) => userModel.toJson()).toList();
  }

  // from JSON List
  static List<UserApiModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => UserApiModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // to Entity
  UserEntity toEntity() {
    return UserEntity(
      userId: id,
      email: email,
      role: role,
      isVerified: isVerified,
      isPermanentlyBanned: isPermanentlyBanned,
      banReason: banReason,
      bannedAt: bannedAt,
      bannedFrom: bannedFrom,
      bannedTo: bannedTo,
    );
  }

  // from Entity
  factory UserApiModel.fromEntity(UserEntity userEntity) {
    return UserApiModel(
      id: userEntity.userId,
      email: userEntity.email,
      role: userEntity.role,
      isVerified: userEntity.isVerified,
      isPermanentlyBanned: userEntity.isPermanentlyBanned,
      banReason: userEntity.banReason,
      bannedAt: userEntity.bannedAt,
      bannedFrom: userEntity.bannedFrom,
      bannedTo: userEntity.bannedTo,
    );
  }

  // to Entity List
  static List<UserEntity> toEntityList(List<UserApiModel> userModels) {
    return userModels.map((userModel) => userModel.toEntity()).toList();
  }

  // from Entity List
  static List<UserApiModel> fromEntityList(List<UserEntity> userEntities) {
    return userEntities
        .map((userEntity) => UserApiModel.fromEntity(userEntity))
        .toList();
  }
}
