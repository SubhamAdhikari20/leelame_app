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
  final String? userId;
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
    this.userId,
    this.baseUser,
  });

  // to JSON
  Map<String, dynamic> toJson() {
    return {
      "fullName": fullName,
      "username": username,
      "contact": phoneNumber,
      "password": password,
      "profilePictureUrl": profilePictureUrl,
      "bio": bio,
      "terms": termsAccepted,
      "userId": userId,
      "baseUser": baseUser,
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
      userId: json["userId"] as String?,
      baseUser: json["baseUser"] != null
          ? UserApiModel.fromJson(json["baseUser"] as Map<String, dynamic>)
          : null,
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
      userId: userId,
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
      userId: buyerEntity.userId,
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
