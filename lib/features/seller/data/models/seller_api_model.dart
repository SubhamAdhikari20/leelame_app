// lib/features/buyer/data/models/seller_api_model.dart
import 'package:leelame/features/auth/data/models/user_api_model.dart';
import 'package:leelame/features/seller/domain/entities/seller_entity.dart';

class SellerApiModel {
  final String? id;
  final String fullName;
  final String? phoneNumber;
  final String? password;
  final String? profilePictureUrl;
  final String? bio;
  final String? baseUserId;
  final UserApiModel? baseUser;

  final String? sellerNotes;
  final String? sellerStatus;
  final DateTime? sellerVerificationDate;
  final int? sellerAttemptCount;
  final int? sellerRuleViolationCount;
  final bool? isSellerPermanentlyBanned;
  final DateTime? sellerBannedAt;
  final DateTime? sellerBannedDateFrom;
  final DateTime? sellerBannedDateTo;

  SellerApiModel({
    this.id,
    required this.fullName,
    this.phoneNumber,
    this.password,
    this.profilePictureUrl,
    this.bio,
    this.baseUserId,
    this.baseUser,
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

  // to JSON
  Map<String, dynamic> toJson({UserApiModel? userApiModel}) {
    return {
      "fullName": fullName,
      "contact": phoneNumber,
      "password": password,
      "profilePictureUrl": profilePictureUrl,
      "bio": bio,
      "baseUserId": baseUserId ?? baseUser?.id ?? userApiModel?.id,
      "email": baseUser?.email ?? userApiModel?.email,
      "role": baseUser?.role ?? userApiModel?.role,
      "isVerified": baseUser?.isVerified ?? userApiModel?.isVerified,
      "isPermanentlyBanned":
          baseUser?.isPermanentlyBanned ?? userApiModel?.isPermanentlyBanned,
      "banReason": baseUser?.banReason ?? userApiModel?.banReason,
      "bannedAt": baseUser?.bannedAt ?? userApiModel?.bannedAt,
      "bannedFrom": baseUser?.bannedFrom ?? userApiModel?.bannedFrom,
      "bannedTo": baseUser?.bannedTo ?? userApiModel?.bannedTo,
      "sellerNotes": sellerNotes,
      "sellerStatus": sellerStatus,
      "sellerVerificationDate": sellerVerificationDate?.toIso8601String(),
      "sellerAttemptCount": sellerAttemptCount,
      "sellerRuleViolationCount": sellerRuleViolationCount,
      "isSellerPermanentlyBanned": isSellerPermanentlyBanned,
      "sellerBannedAt": sellerBannedAt?.toIso8601String(),
      "sellerBannedDateFrom": sellerBannedDateFrom?.toIso8601String(),
      "sellerBannedDateTo": sellerBannedDateTo?.toIso8601String(),
    };
  }

  // From JSON
  factory SellerApiModel.fromJson(Map<String, dynamic> json) {
    return SellerApiModel(
      id: json["_id"] as String,
      fullName: json["fullName"] as String,
      phoneNumber: json["contact"] as String?,
      profilePictureUrl: json["profilePictureUrl"] as String?,
      bio: json["bio"] as String?,
      baseUserId: json["baseUserId"] as String?,
      baseUser: UserApiModel(
        email: json["email"] as String,
        role: json["role"] as String,
        isVerified: json["isVerified"] as bool,
        isPermanentlyBanned: json["isPermanentlyBanned"] as bool,
        banReason: json["banReason"] as String?,
        bannedAt: json["bannedAt"] != null
            ? DateTime.parse(json["bannedAt"])
            : null,
        bannedFrom: json["bannedFrom"] != null
            ? DateTime.parse(json["bannedFrom"])
            : null,
        bannedTo: json["bannedTo"] != null
            ? DateTime.parse(json["bannedTo"])
            : null,
      ),
      // baseUser: json["baseUser"] != null
      //     ? UserApiModel.fromJson(json["baseUser"] as Map<String, dynamic>)
      //     : null,
      sellerNotes: json["sellerNotes"] as String?,
      sellerStatus: json["sellerStatus"] as String?,
      sellerVerificationDate: json["sellerVerificationDate"] != null
          ? DateTime.parse(json["sellerVerificationDate"])
          : null,
      sellerAttemptCount: json["sellerAttemptCount"] as int?,
      sellerRuleViolationCount: json["sellerRuleViolationCount"] as int?,
      isSellerPermanentlyBanned: json["isSellerPermanentlyBanned"] as bool?,
      sellerBannedAt: json["sellerBannedAt"] != null
          ? DateTime.parse(json["sellerBannedAt"])
          : null,
      sellerBannedDateFrom: json["sellerBannedDateFrom"] != null
          ? DateTime.parse(json["sellerBannedDateFrom"])
          : null,
      sellerBannedDateTo: json["sellerBannedDateTo"] != null
          ? DateTime.parse(json["sellerBannedDateTo"])
          : null,
    );
  }

  // to JSON List
  static List<Map<String, dynamic>> toJsonList(
    List<SellerApiModel> sellerModels,
  ) {
    return sellerModels.map((sellerModel) => sellerModel.toJson()).toList();
  }

  // from JSON List
  static List<SellerApiModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => SellerApiModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // to Entity
  SellerEntity toEntity() {
    return SellerEntity(
      sellerId: id,
      fullName: fullName,
      phoneNumber: phoneNumber,
      profilePictureUrl: profilePictureUrl,
      bio: bio,
      baseUserId: baseUserId,
      userEntity: baseUser?.toEntity(),
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
  factory SellerApiModel.fromEntity(SellerEntity sellerEntity) {
    return SellerApiModel(
      id: sellerEntity.sellerId,
      fullName: sellerEntity.fullName,
      phoneNumber: sellerEntity.phoneNumber,
      password: sellerEntity.password,
      profilePictureUrl: sellerEntity.profilePictureUrl,
      bio: sellerEntity.bio,
      baseUserId: sellerEntity.baseUserId,
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

  // to Entity List
  static List<SellerEntity> toEntityList(List<SellerApiModel> sellerModels) {
    return sellerModels.map((sellerModel) => sellerModel.toEntity()).toList();
  }

  // from Entity List
  static List<SellerApiModel> fromEntityList(
    List<SellerEntity> sellerEntities,
  ) {
    return sellerEntities
        .map((sellerEntity) => SellerApiModel.fromEntity(sellerEntity))
        .toList();
  }
}
