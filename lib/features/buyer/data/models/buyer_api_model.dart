// lib/features/buyer/data/models/buyer_api_model.dart
import 'package:leelame/features/auth/data/models/user_api_model.dart';
import 'package:leelame/features/buyer/domain/entities/buyer_entity.dart';

class BuyerApiModel {
  final String? id;
  final String fullName;
  final String? username;
  final String? phoneNumber;
  final String? password;
  final String? profilePictureUrl;
  final String? bio;
  final bool? termsAccepted;
  final String? baseUserId;
  final UserApiModel? baseUser;

  BuyerApiModel({
    this.id,
    required this.fullName,
    this.username,
    this.phoneNumber,
    this.password,
    this.profilePictureUrl,
    this.bio,
    this.termsAccepted,
    this.baseUserId,
    this.baseUser,
  });

  // to JSON
  Map<String, dynamic> toJson({UserApiModel? userApiModel}) {
    return {
      "fullName": fullName,
      "username": username,
      "contact": phoneNumber,
      "password": password,
      "profilePictureUrl": profilePictureUrl,
      "bio": bio,
      "terms": termsAccepted,
      "baseUserId": baseUserId ?? baseUser?.id ?? userApiModel?.id,
      "email": baseUser?.email ?? userApiModel?.email,
      "role": baseUser?.role ?? userApiModel?.role,
      "isVerified": baseUser?.isVerified ?? userApiModel?.isVerified,
      "isPermanentlyBanned": baseUser?.isVerified ?? userApiModel?.isVerified,
      "banReason": baseUser?.banReason ?? userApiModel?.banReason,
      "bannedAt": baseUser?.bannedAt ?? userApiModel?.bannedAt,
      "bannedFrom": baseUser?.bannedFrom ?? userApiModel?.bannedFrom,
      "bannedTo": baseUser?.bannedTo ?? userApiModel?.bannedTo,
    };
  }

  // From JSON
  factory BuyerApiModel.fromJson(Map<String, dynamic> json) {
    return BuyerApiModel(
      id: json["_id"] as String,
      fullName: json["fullName"] as String,
      username: json["username"] as String,
      phoneNumber: json["contact"] as String?,
      profilePictureUrl: json["profilePictureUrl"] as String?,
      bio: json["bio"] as String?,
      termsAccepted: json["terms"] as bool?,
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
    );
  }

  // to JSON List
  static List<Map<String, dynamic>> toJsonList(
    List<BuyerApiModel> buyerModels,
  ) {
    return buyerModels.map((buyerModel) => buyerModel.toJson()).toList();
  }

  // from JSON List
  static List<BuyerApiModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => BuyerApiModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // to Entity
  BuyerEntity toEntity() {
    return BuyerEntity(
      buyerId: id,
      fullName: fullName,
      username: username,
      phoneNumber: phoneNumber,
      profilePictureUrl: profilePictureUrl,
      bio: bio,
      termsAccepted: termsAccepted,
      baseUserId: baseUserId,
      userEntity: baseUser?.toEntity(),
    );
  }

  // from Entity
  factory BuyerApiModel.fromEntity(BuyerEntity buyerEntity) {
    return BuyerApiModel(
      id: buyerEntity.buyerId,
      fullName: buyerEntity.fullName,
      username: buyerEntity.username,
      phoneNumber: buyerEntity.phoneNumber,
      password: buyerEntity.password,
      profilePictureUrl: buyerEntity.profilePictureUrl,
      bio: buyerEntity.bio,
      termsAccepted: buyerEntity.termsAccepted,
      baseUserId: buyerEntity.baseUserId,
    );
  }

  // to Entity List
  static List<BuyerEntity> toEntityList(List<BuyerApiModel> buyerModels) {
    return buyerModels.map((buyerModel) => buyerModel.toEntity()).toList();
  }

  // from Entity List
  static List<BuyerApiModel> fromEntityList(List<BuyerEntity> buyerEntities) {
    return buyerEntities
        .map((buyerEntity) => BuyerApiModel.fromEntity(buyerEntity))
        .toList();
  }
}
