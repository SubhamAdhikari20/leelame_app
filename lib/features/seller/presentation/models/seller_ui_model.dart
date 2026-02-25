// lib/features/buyer/data/models/seller_ui_model.dart
import 'package:leelame/features/auth/presentation/models/user_ui_model.dart';
import 'package:leelame/features/seller/domain/entities/seller_entity.dart';

class SellerUiModel {
  final String? sellerId;
  final String fullName;
  final String? phoneNumber;
  final String? password;
  final String? profilePictureUrl;
  final String? bio;
  final String? baseUserId;
  final UserUiModel? userUiModel;

  final String? sellerNotes;
  final String? sellerStatus;
  final DateTime? sellerVerificationDate;
  final int? sellerAttemptCount;
  final int? sellerRuleViolationCount;
  final bool? isSellerPermanentlyBanned;
  final DateTime? sellerBannedAt;
  final DateTime? sellerBannedDateFrom;
  final DateTime? sellerBannedDateTo;

  SellerUiModel({
    this.sellerId,
    required this.fullName,
    this.phoneNumber,
    this.password,
    this.profilePictureUrl,
    this.bio,
    this.baseUserId,
    this.userUiModel,
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

  // to Entity
  SellerEntity toEntity() {
    return SellerEntity(
      sellerId: sellerId,
      fullName: fullName,
      phoneNumber: phoneNumber,
      profilePictureUrl: profilePictureUrl,
      bio: bio,
      baseUserId: baseUserId,
      userEntity: userUiModel?.toEntity(),
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

  // from Entity
  factory SellerUiModel.fromEntity(SellerEntity sellerEntity) {
    return SellerUiModel(
      sellerId: sellerEntity.sellerId,
      fullName: sellerEntity.fullName,
      phoneNumber: sellerEntity.phoneNumber,
      password: sellerEntity.password,
      profilePictureUrl: sellerEntity.profilePictureUrl,
      bio: sellerEntity.bio,
      baseUserId: sellerEntity.baseUserId,
      userUiModel: sellerEntity.userEntity != null
          ? UserUiModel.fromEntity(sellerEntity.userEntity!)
          : null,
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

  // to Entity List
  static List<SellerEntity> toEntityList(List<SellerUiModel> sellerModels) {
    return sellerModels.map((sellerModel) => sellerModel.toEntity()).toList();
  }

  // from Entity List
  static List<SellerUiModel> fromEntityList(List<SellerEntity> sellerEntities) {
    return sellerEntities
        .map((sellerEntity) => SellerUiModel.fromEntity(sellerEntity))
        .toList();
  }

  SellerUiModel copyWith({
    String? sellerId,
    String? fullName,
    String? phoneNumber,
    String? password,
    String? profilePictureUrl,
    String? bio,
    String? baseUserId,
    UserUiModel? userUiModel,
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
    return SellerUiModel(
      sellerId: sellerId ?? this.sellerId,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      password: password ?? this.password,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      bio: bio ?? this.bio,
      baseUserId: baseUserId ?? this.baseUserId,
      userUiModel: userUiModel ?? this.userUiModel,
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
