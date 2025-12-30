// lib/features/auth/domain/entities/buyer_entity.dart
import 'package:equatable/equatable.dart';

class BuyerEntity extends Equatable {
  final String? id;
  final String fullName;
  final String? username;
  final String? mobileNumber;
  final String? password;
  final String? profilePictureUrl;
  final String? bio;
  final bool termsAccepted;

  // Reference from base user
  final String userId;

  const BuyerEntity({
    this.id,
    required this.fullName,
    this.username,
    this.mobileNumber,
    this.password,
    this.profilePictureUrl,
    this.bio,
    required this.termsAccepted,
    required this.userId,
  });

  @override
  List<Object?> get props => [
    id,
    fullName,
    username,
    mobileNumber,
    password,
    profilePictureUrl,
    bio,
    termsAccepted,
    userId,
  ];
}
