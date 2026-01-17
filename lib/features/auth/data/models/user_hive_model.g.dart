// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserHiveModelAdapter extends TypeAdapter<UserHiveModel> {
  @override
  final int typeId = 0;

  @override
  UserHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserHiveModel(
      userId: fields[0] as String?,
      email: fields[1] as String,
      role: fields[2] as String,
      isVerified: fields[3] as bool,
      isPermanentlyBanned: fields[4] as bool,
      banReason: fields[5] as String?,
      bannedAt: fields[6] as DateTime?,
      bannedFrom: fields[7] as DateTime?,
      bannedTo: fields[8] as DateTime?,
      verifyCode: fields[9] as String?,
      verifyCodeExpiryDate: fields[10] as DateTime?,
      verifyEmailResetPassword: fields[11] as String?,
      verifyEmailResetPasswordExpiryDate: fields[12] as DateTime?,
      pendingOtpSend: fields[13] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, UserHiveModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.role)
      ..writeByte(3)
      ..write(obj.isVerified)
      ..writeByte(4)
      ..write(obj.isPermanentlyBanned)
      ..writeByte(5)
      ..write(obj.banReason)
      ..writeByte(6)
      ..write(obj.bannedAt)
      ..writeByte(7)
      ..write(obj.bannedFrom)
      ..writeByte(8)
      ..write(obj.bannedTo)
      ..writeByte(9)
      ..write(obj.verifyCode)
      ..writeByte(10)
      ..write(obj.verifyCodeExpiryDate)
      ..writeByte(11)
      ..write(obj.verifyEmailResetPassword)
      ..writeByte(12)
      ..write(obj.verifyEmailResetPasswordExpiryDate)
      ..writeByte(13)
      ..write(obj.pendingOtpSend);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
