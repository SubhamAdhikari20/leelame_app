// lib/features/auth/presentation/models/user_ui_model.dart
import 'package:leelame/features/auth/domain/entities/user_entity.dart';

class UserUiModel {
  final String? userId;
  final String email;
  final String role;
  final bool isVerified;
  
  final bool isPermanentlyBanned;
  final String? banReason;
  final DateTime? bannedAt;
  final DateTime? bannedFrom;
  final DateTime? bannedTo;

  final String? verifyCode;
  final DateTime? verifyCodeExpiryDate;
  final String? verifyEmailResetPassword;
  final DateTime? verifyEmailResetPasswordExpiryDate;

  const UserUiModel({
    this.userId,
    required this.email,
    required this.role,
    required this.isVerified,
    required this.isPermanentlyBanned,
    this.banReason,
    this.bannedAt,
    this.bannedFrom,
    this.bannedTo,
    this.verifyCode,
    this.verifyCodeExpiryDate,
    this.verifyEmailResetPassword,
    this.verifyEmailResetPasswordExpiryDate,
  });

  // to Entity
  UserEntity toEntity() {
    return UserEntity(
      userId: userId,
      email: email,
      role: role,
      isVerified: isVerified,
      isPermanentlyBanned: isPermanentlyBanned,
      verifyCode: verifyCode,
      verifyCodeExpiryDate: verifyCodeExpiryDate,
      verifyEmailResetPassword: verifyEmailResetPassword,
      verifyEmailResetPasswordExpiryDate: verifyEmailResetPasswordExpiryDate,
      banReason: banReason,
      bannedAt: bannedAt,
      bannedFrom: bannedFrom,
      bannedTo: bannedTo,
    );
  }

  // from Entity
  factory UserUiModel.fromEntity(UserEntity userEntity) {
    return UserUiModel(
      userId: userEntity.userId,
      email: userEntity.email,
      role: userEntity.role,
      isVerified: userEntity.isVerified,
      isPermanentlyBanned: userEntity.isPermanentlyBanned,
      verifyCode: userEntity.verifyCode,
      verifyCodeExpiryDate: userEntity.verifyCodeExpiryDate,
      verifyEmailResetPassword: userEntity.verifyEmailResetPassword,
      verifyEmailResetPasswordExpiryDate:
          userEntity.verifyEmailResetPasswordExpiryDate,
      banReason: userEntity.banReason,
      bannedAt: userEntity.bannedAt,
      bannedFrom: userEntity.bannedFrom,
      bannedTo: userEntity.bannedTo,
    );
  }

  // to Entity List
  static List<UserEntity> toEntityList(List<UserUiModel> userUiModels) {
    return userUiModels.map((userModel) => userModel.toEntity()).toList();
  }

  // from Entity List
  static List<UserUiModel> fromEntityList(List<UserEntity> userEntities) {
    return userEntities
        .map((userEntity) => UserUiModel.fromEntity(userEntity))
        .toList();
  }

  UserUiModel copyWith({
    String? userId,
    String? email,
    String? role,
    bool? isVerified,
    bool? isPermanentlyBanned,
    String? banReason,
    DateTime? bannedAt,
    DateTime? bannedFrom,
    DateTime? bannedTo,
    String? verifyCode,
    DateTime? verifyCodeExpiryDate,
    String? verifyEmailResetPassword,
    DateTime? verifyEmailResetPasswordExpiryDate,
  }) {
    return UserUiModel(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      isPermanentlyBanned: isPermanentlyBanned ?? this.isPermanentlyBanned,
      banReason: banReason ?? this.banReason,
      bannedAt: bannedAt ?? this.bannedAt,
      bannedFrom: bannedFrom ?? this.bannedFrom,
      bannedTo: bannedTo ?? this.bannedTo,
      verifyCode: verifyCode ?? this.verifyCode,
      verifyCodeExpiryDate: verifyCodeExpiryDate ?? this.verifyCodeExpiryDate,
      verifyEmailResetPassword:
          verifyEmailResetPassword ?? this.verifyEmailResetPassword,
      verifyEmailResetPasswordExpiryDate:
          verifyEmailResetPasswordExpiryDate ??
          this.verifyEmailResetPasswordExpiryDate,
    );
  }
}
