// lib/features/auth/data/models/user_api_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:leelame/features/auth/domain/entities/user_entity.dart';

part "user_api_model.g.dart";

@JsonSerializable()
class UserApiModel {
  @JsonKey(name: "_id")
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

  // to Json
  Map<String, dynamic> toJson() {
    return _$UserApiModelToJson(this);
  }

  // From JSON
  factory UserApiModel.fromJson(Map<String, dynamic> json) {
    return _$UserApiModelFromJson(json);
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
