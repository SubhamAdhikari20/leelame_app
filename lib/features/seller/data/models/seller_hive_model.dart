// lib/features/seller/data/models/seller_hive_model.dart
import 'package:hive/hive.dart';
import 'package:leelame/core/constants/hive_table_constant.dart';
import 'package:leelame/features/auth/domain/entities/user_entity.dart';
import 'package:leelame/features/seller/domain/entities/seller_entity.dart';
import 'package:uuid/uuid.dart';

part "seller_hive_model.g.dart";

@HiveType(typeId: HiveTableConstant.sellersTypeId)
class SellerHiveModel extends HiveObject {
  @HiveField(0)
  final String? sellerId;

  @HiveField(1)
  final String fullName;

  @HiveField(2)
  final String? phoneNumber;

  @HiveField(3)
  final String? password;

  @HiveField(4)
  final String? profilePictureUrl;

  @HiveField(5)
  final String? bio;

  @HiveField(6)
  final String? userId;

  @HiveField(7)
  final String? sellerNotes;

  @HiveField(8)
  final String? sellerStatus;

  @HiveField(9)
  final DateTime? sellerVerificationDate;

  @HiveField(10)
  final int? sellerAttemptCount;

  @HiveField(11)
  final int? sellerRuleViolationCount;

  @HiveField(12)
  final bool? isSellerPermanentlyBanned;

  @HiveField(13)
  final DateTime? sellerBannedAt;

  @HiveField(14)
  final DateTime? sellerBannedDateFrom;

  @HiveField(15)
  final DateTime? sellerBannedDateTo;

  SellerHiveModel({
    String? sellerId,
    required this.fullName,
    this.phoneNumber,
    this.password,
    this.profilePictureUrl,
    this.bio,
    String? userId,
    this.sellerNotes,
    this.sellerStatus,
    this.sellerVerificationDate,
    this.sellerAttemptCount,
    this.sellerRuleViolationCount,
    this.isSellerPermanentlyBanned,
    this.sellerBannedAt,
    this.sellerBannedDateFrom,
    this.sellerBannedDateTo,
  }) : sellerId = sellerId ?? Uuid().v4(),
       userId = userId ?? Uuid().v4();

  // Convert Model to Seller Entity
  SellerEntity toEntity({UserEntity? userEntity}) {
    return SellerEntity(
      sellerId: sellerId,
      fullName: fullName,
      phoneNumber: phoneNumber,
      password: password,
      profilePictureUrl: profilePictureUrl,
      bio: bio,
      userId: userId,
      userEntity: userEntity,
      sellerNotes: sellerNotes,
      sellerStatus: sellerStatus,
      sellerVerificationDate: sellerVerificationDate,
      sellerAttemptCount: sellerAttemptCount,
      sellerRuleViolationCount: sellerRuleViolationCount,
      isSellerPermanentlyBanned: isSellerPermanentlyBanned,
      sellerBannedAt: sellerBannedAt,
      sellerBannedDateFrom: sellerBannedDateFrom,
      sellerBannedDateTo: sellerBannedDateTo,
    );
  }

  // Convert Seller Entity to Model
  factory SellerHiveModel.fromEntity(SellerEntity sellerEntity) {
    return SellerHiveModel(
      sellerId: sellerEntity.sellerId,
      fullName: sellerEntity.fullName,
      phoneNumber: sellerEntity.phoneNumber,
      password: sellerEntity.password,
      profilePictureUrl: sellerEntity.profilePictureUrl,
      bio: sellerEntity.bio,
      userId: sellerEntity.userId,
      sellerNotes: sellerEntity.sellerNotes,
      sellerStatus: sellerEntity.sellerStatus,
      sellerVerificationDate: sellerEntity.sellerVerificationDate,
      sellerAttemptCount: sellerEntity.sellerAttemptCount,
      sellerRuleViolationCount: sellerEntity.sellerRuleViolationCount,
      isSellerPermanentlyBanned: sellerEntity.isSellerPermanentlyBanned,
      sellerBannedAt: sellerEntity.sellerBannedAt,
      sellerBannedDateFrom: sellerEntity.sellerBannedDateFrom,
      sellerBannedDateTo: sellerEntity.sellerBannedDateTo,
    );
  }

  // Convert List of Models to List of Seller Entities
  static List<SellerEntity> toEntityList(List<SellerHiveModel> sellerModels) {
    return sellerModels.map((sellerModel) => sellerModel.toEntity()).toList();
  }

  // copyWith helper to create updated instances (used before saving to Hive)
  SellerHiveModel copyWith({
    String? sellerId,
    String? fullName,
    String? phoneNumber,
    String? password,
    String? profilePictureUrl,
    String? bio,
    String? userId,
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
    return SellerHiveModel(
      sellerId: sellerId ?? this.sellerId,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      password: password ?? this.password,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      bio: bio ?? this.bio,
      userId: userId ?? this.userId,
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
