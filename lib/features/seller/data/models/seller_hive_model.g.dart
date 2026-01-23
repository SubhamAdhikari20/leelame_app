// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seller_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SellerHiveModelAdapter extends TypeAdapter<SellerHiveModel> {
  @override
  final int typeId = 3;

  @override
  SellerHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SellerHiveModel(
      sellerId: fields[0] as String?,
      fullName: fields[1] as String,
      phoneNumber: fields[2] as String?,
      password: fields[3] as String?,
      profilePictureUrl: fields[4] as String?,
      bio: fields[5] as String?,
      userId: fields[6] as String?,
      sellerNotes: fields[7] as String?,
      sellerStatus: fields[8] as String?,
      sellerVerificationDate: fields[9] as DateTime?,
      sellerAttemptCount: fields[10] as int?,
      sellerRuleViolationCount: fields[11] as int?,
      isSellerPermanentlyBanned: fields[12] as bool?,
      sellerBannedAt: fields[13] as DateTime?,
      sellerBannedDateFrom: fields[14] as DateTime?,
      sellerBannedDateTo: fields[15] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, SellerHiveModel obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.sellerId)
      ..writeByte(1)
      ..write(obj.fullName)
      ..writeByte(2)
      ..write(obj.phoneNumber)
      ..writeByte(3)
      ..write(obj.password)
      ..writeByte(4)
      ..write(obj.profilePictureUrl)
      ..writeByte(5)
      ..write(obj.bio)
      ..writeByte(6)
      ..write(obj.userId)
      ..writeByte(7)
      ..write(obj.sellerNotes)
      ..writeByte(8)
      ..write(obj.sellerStatus)
      ..writeByte(9)
      ..write(obj.sellerVerificationDate)
      ..writeByte(10)
      ..write(obj.sellerAttemptCount)
      ..writeByte(11)
      ..write(obj.sellerRuleViolationCount)
      ..writeByte(12)
      ..write(obj.isSellerPermanentlyBanned)
      ..writeByte(13)
      ..write(obj.sellerBannedAt)
      ..writeByte(14)
      ..write(obj.sellerBannedDateFrom)
      ..writeByte(15)
      ..write(obj.sellerBannedDateTo);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SellerHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
