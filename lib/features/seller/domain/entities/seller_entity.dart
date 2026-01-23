// lib/features/seller/domain/entities/seller_entity.dart
import 'package:equatable/equatable.dart';
import 'package:leelame/features/auth/domain/entities/user_entity.dart';

class SellerEntity extends Equatable {
  final String? sellerId;
  final String fullName;
  final String? phoneNumber;
  final String? password;
  final String? profilePictureUrl;
  final String? bio;

  final String? userId;
  final UserEntity? userEntity;

  final String? sellerNotes;
  final String? sellerStatus;
  final DateTime? sellerVerificationDate;
  final int? sellerAttemptCount;
  final int? sellerRuleViolationCount;
  final bool? isSellerPermanentlyBanned;
  final DateTime? sellerBannedAt;
  final DateTime? sellerBannedDateFrom;
  final DateTime? sellerBannedDateTo;

  const SellerEntity({
    this.sellerId,
    required this.fullName,
    this.phoneNumber,
    this.password,
    this.profilePictureUrl,
    this.bio,
    this.userId,
    this.userEntity,
    this.sellerNotes,
    this.sellerStatus,
    this.sellerVerificationDate,
    this.sellerAttemptCount,
    this.sellerRuleViolationCount,
    this.isSellerPermanentlyBanned,
    this.sellerBannedAt,
    this.sellerBannedDateFrom,
    this.sellerBannedDateTo,
  });

  @override
  List<Object?> get props => [
    sellerId,
    fullName,
    phoneNumber,
    password,
    profilePictureUrl,
    bio,
    userId,
    userEntity,
    sellerNotes,
    sellerStatus,
    sellerVerificationDate,
    sellerAttemptCount,
    sellerRuleViolationCount,
    isSellerPermanentlyBanned,
    sellerBannedAt,
    sellerBannedDateFrom,
    sellerBannedDateTo,
  ];
}
