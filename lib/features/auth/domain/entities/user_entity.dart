// lib/features/auth/domain/entities/user_entity.dart
import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  // userId is optional because we dont need userId while adding but required when updating and deleting
  final String? userId;
  final String email;
  final String role;
  final bool isVerified;

  const UserEntity({
    this.userId,
    required this.email,
    required this.role,
    required this.isVerified,
  });

  @override
  List<Object?> get props => [userId, email, role, isVerified];
}
