// lib/features/auth/domain/entities/user_entity.dart
import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String? userId;
  final String email;
  final String role;
  final bool isVerified;

  // Moderation
  final bool isPermanentlyBanned;
  final String? banReason;
  final DateTime? bannedAt;
  final DateTime? bannedFrom;
  final DateTime? bannedTo;

  // Verify Account with OTP and Expiry Time
  final String? verifyCode;
  final DateTime? verifyCodeExpiryDate;
  final String? verifyEmailResetPassword;
  final DateTime? verifyEmailResetPasswordExpiryDate;

  bool get isBanned =>
      isPermanentlyBanned ||
      (bannedFrom != null &&
          bannedTo != null &&
          DateTime.now().isAfter(bannedFrom!) &&
          DateTime.now().isBefore(bannedTo!));

  const UserEntity({
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

  @override
  List<Object?> get props => [
    userId,
    email,
    role,
    isVerified,
    isPermanentlyBanned,
    banReason,
    bannedAt,
    bannedFrom,
    bannedTo,
    verifyCode,
    verifyCodeExpiryDate,
    verifyEmailResetPassword,
    verifyEmailResetPasswordExpiryDate,
  ];

  UserEntity copyWith({
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
    return UserEntity(
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
