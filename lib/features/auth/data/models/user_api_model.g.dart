// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserApiModel _$UserApiModelFromJson(Map<String, dynamic> json) => UserApiModel(
      id: json['_id'] as String?,
      email: json['email'] as String,
      role: json['role'] as String,
      isVerified: json['isVerified'] as bool,
      isPermanentlyBanned: json['isPermanentlyBanned'] as bool,
      banReason: json['banReason'] as String?,
      bannedAt: json['bannedAt'] == null
          ? null
          : DateTime.parse(json['bannedAt'] as String),
      bannedFrom: json['bannedFrom'] == null
          ? null
          : DateTime.parse(json['bannedFrom'] as String),
      bannedTo: json['bannedTo'] == null
          ? null
          : DateTime.parse(json['bannedTo'] as String),
    );

Map<String, dynamic> _$UserApiModelToJson(UserApiModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'email': instance.email,
      'role': instance.role,
      'isVerified': instance.isVerified,
      'isPermanentlyBanned': instance.isPermanentlyBanned,
      'banReason': instance.banReason,
      'bannedAt': instance.bannedAt?.toIso8601String(),
      'bannedFrom': instance.bannedFrom?.toIso8601String(),
      'bannedTo': instance.bannedTo?.toIso8601String(),
    };
