// lib/features/buyer/domain/entities/buyer_entity.dart
import 'package:equatable/equatable.dart';
import 'package:leelame/features/auth/domain/entities/user_entity.dart';

class BuyerEntity extends Equatable {
  final String? buyerId;
  final String fullName;
  final String? username;
  final String? phoneNumber;
  final String? password;
  final String? profilePictureUrl;
  final String? bio;
  final bool? termsAccepted;

  // Reference from base user
  final String? userId;
  final UserEntity? userEntity;

  const BuyerEntity({
    this.buyerId,
    required this.fullName,
    this.username,
    this.phoneNumber,
    this.password,
    this.profilePictureUrl,
    this.bio,
    this.termsAccepted,
    this.userId,
    this.userEntity,
  });

  @override
  List<Object?> get props => [
    buyerId,
    fullName,
    username,
    phoneNumber,
    password,
    profilePictureUrl,
    bio,
    termsAccepted,
    userId,
  ];
}
