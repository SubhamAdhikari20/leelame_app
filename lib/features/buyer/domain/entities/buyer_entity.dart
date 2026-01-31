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
  final String? baseUserId;
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
    this.baseUserId,
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
    baseUserId,
    userEntity,
  ];

  BuyerEntity copyWith({
    String? buyerId,
    String? fullName,
    String? username,
    String? phoneNumber,
    String? password,
    String? profilePictureUrl,
    String? bio,
    bool? termsAccepted,
    String? baseUserId,
    UserEntity? userEntity,
  }) {
    return BuyerEntity(
      buyerId: buyerId ?? this.buyerId,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      password: password ?? this.password,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      bio: bio ?? this.bio,
      termsAccepted: termsAccepted ?? this.termsAccepted,
      baseUserId: baseUserId ?? this.baseUserId,
      userEntity: userEntity ?? this.userEntity,
    );
  }
}
