// lib/features/auth/domain/entities/buyer_entity.dart
import 'package:equatable/equatable.dart';

class BuyerEntity extends Equatable {
  final String? buyerId;
  final String fullName;
  final String? username;
  final String? mobileNumber;
  final String? password;
  final String? profilePictureUrl;
  final String? bio;

  const BuyerEntity({
    this.buyerId,
    required this.fullName,
    this.username,
    this.mobileNumber,
    this.password,
    this.profilePictureUrl,
    this.bio,
  });

  @override
  List<Object?> get props => [
    buyerId,
    fullName,
    username,
    mobileNumber,
    password,
    profilePictureUrl,
    bio,
  ];
}
