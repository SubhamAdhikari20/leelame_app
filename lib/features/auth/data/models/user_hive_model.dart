// lib/features/auth/data/models/user_hive_model.dart
import 'package:hive/hive.dart';
import 'package:leelame/core/constants/hive_table_constant.dart';
import 'package:leelame/features/auth/domain/entities/user_entity.dart';
import 'package:uuid/uuid.dart';

part "user_hive_model.g.dart";

@HiveType(typeId: HiveTableConstant.usersTypeId)
class UserHiveModel extends HiveObject {
  @HiveField(0)
  final String? userId;

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
  final String? verifyCode;

  @HiveField(10)
  final DateTime? verifyCodeExpiryDate;

  @HiveField(11)
  final String? verifyEmailResetPassword;

  @HiveField(12)
  final DateTime? verifyEmailResetPasswordExpiryDate;

  @HiveField(13)
  final bool pendingOtpSend;

  // @HiveField(13)
  // final String? buyerProfileId;

  // @HiveField(14)
  // final String? sellerProfileId;

  UserHiveModel({
    String? userId,
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
    this.pendingOtpSend = false,
    // this.buyerProfileId,
    // this.sellerProfileId,
  }) : userId = userId ?? Uuid().v4();

  // Convert Model to User Entity
  UserEntity toEntity() {
    return UserEntity(
      userId: userId,
      email: email,
      role: role,
      isVerified: isVerified,
      isPermanentlyBanned: isPermanentlyBanned,
      banReason: banReason,
      bannedAt: bannedAt,
      bannedFrom: bannedFrom,
      bannedTo: bannedTo,
      verifyCode: verifyCode,
      verifyCodeExpiryDate: verifyCodeExpiryDate,
      verifyEmailResetPassword: verifyEmailResetPassword,
      verifyEmailResetPasswordExpiryDate: verifyEmailResetPasswordExpiryDate,
      // buyerId: buyerProfileId,
      // sellerId: sellerProfileId,
    );
  }

  // Convert User Entity to Model
  factory UserHiveModel.fromEntity(UserEntity userEntity) {
    return UserHiveModel(
      userId: userEntity.userId,
      email: userEntity.email,
      role: userEntity.role,
      isVerified: userEntity.isVerified,
      isPermanentlyBanned: userEntity.isPermanentlyBanned,
      banReason: userEntity.banReason,
      bannedAt: userEntity.bannedAt,
      bannedFrom: userEntity.bannedFrom,
      bannedTo: userEntity.bannedTo,
      verifyCode: userEntity.verifyCode,
      verifyCodeExpiryDate: userEntity.verifyCodeExpiryDate,
      verifyEmailResetPassword: userEntity.verifyEmailResetPassword,
      verifyEmailResetPasswordExpiryDate:
          userEntity.verifyEmailResetPasswordExpiryDate,
      // buyerProfileId: userEntity.buyerId,
      // sellerProfileId: userEntity.sellerId,
    );
  }

  // Convert List of Models to List of User Entities
  static List<UserEntity> toEntityList(List<UserHiveModel> userModels) {
    return userModels.map((userModel) => userModel.toEntity()).toList();
  }

  // copyWith helper to create updated instances (used before saving to Hive)
  UserHiveModel copyWith({
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
    bool? pendingOtpSend,
  }) {
    return UserHiveModel(
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
      pendingOtpSend: pendingOtpSend ?? this.pendingOtpSend,
    );
  }
}
