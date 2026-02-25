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

  final String? baseUserId;
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
    this.baseUserId,
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
    baseUserId,
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

  SellerEntity copyWith({
    String? sellerId,
    String? fullName,
    String? phoneNumber,
    String? password,
    String? profilePictureUrl,
    String? bio,
    String? baseUserId,
    UserEntity? userEntity,
    String? sellerNotes,
    String? sellerStatus,
    DateTime? sellerVerificationDate,
    int? sellerAttemptCount,
    int? sellerRuleViolationCount,
    bool? isSellerPermanentlyBanned,
    DateTime? sellerBannedAt,
    DateTime? sellerBannedDateFrom,
    DateTime? sellerBannedDateTo,
  }) {
    return SellerEntity(
      sellerId: sellerId ?? this.sellerId,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      password: password ?? this.password,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      bio: bio ?? this.bio,
      baseUserId: baseUserId ?? this.baseUserId,
      userEntity: userEntity ?? this.userEntity,
      sellerNotes: sellerNotes ?? this.sellerNotes,
      sellerStatus: sellerStatus ?? this.sellerStatus,
      sellerVerificationDate:
          sellerVerificationDate ?? this.sellerVerificationDate,
      sellerAttemptCount: sellerAttemptCount ?? this.sellerAttemptCount,
      sellerRuleViolationCount:
          sellerRuleViolationCount ?? this.sellerRuleViolationCount,
      isSellerPermanentlyBanned:
          isSellerPermanentlyBanned ?? this.isSellerPermanentlyBanned,
      sellerBannedAt: sellerBannedAt ?? this.sellerBannedAt,
      sellerBannedDateFrom: sellerBannedDateFrom ?? this.sellerBannedDateFrom,
      sellerBannedDateTo: sellerBannedDateTo ?? this.sellerBannedDateTo,
    );
  }
}
