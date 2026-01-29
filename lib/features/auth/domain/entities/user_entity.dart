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

  // Users references
  // final String? buyerId;
  // final String? sellerId;

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
    // this.buyerId,
    // this.sellerId,
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
    // buyerId,
    // sellerId,
  ];
}
