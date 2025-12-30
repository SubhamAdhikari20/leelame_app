// lib/features/auth/domain/entities/user_entity.dart
import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  // id is optional because we dont need id while adding but required when updating and deleting
  final String? id;
  final String email;
  final String role;
  final bool isVerified;

  // Moderation
  final bool isPermanentlyBanned;
  final String? banReason;
  final DateTime? bannedAt;
  final DateTime? bannedFrom;
  final DateTime? bannedTo;

  // Users references
  final String? buyerId;
  final String? sellerId;

  bool get isBanned =>
      isPermanentlyBanned ||
      (bannedFrom != null &&
          bannedTo != null &&
          DateTime.now().isAfter(bannedFrom!) &&
          DateTime.now().isBefore(bannedTo!));

  const UserEntity({
    this.id,
    required this.email,
    required this.role,
    required this.isVerified,
    required this.isPermanentlyBanned,
    this.banReason,
    this.bannedAt,
    this.bannedFrom,
    this.bannedTo,
    this.buyerId,
    this.sellerId,
  });

  @override
  List<Object?> get props => [
    id,
    email,
    role,
    isVerified,
    isPermanentlyBanned,
    banReason,
    bannedAt,
    bannedFrom,
    bannedTo,
    buyerId,
    sellerId,
  ];
}
