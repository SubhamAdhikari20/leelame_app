// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'buyer_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BuyerHiveModelAdapter extends TypeAdapter<BuyerHiveModel> {
  @override
  final int typeId = 1;

  @override
  BuyerHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BuyerHiveModel(
      buyerId: fields[0] as String?,
      fullName: fields[1] as String,
      username: fields[2] as String?,
      phoneNumber: fields[3] as String?,
      password: fields[4] as String?,
      profilePictureUrl: fields[5] as String?,
      bio: fields[6] as String?,
      termsAccepted: fields[7] as bool?,
      userId: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, BuyerHiveModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.buyerId)
      ..writeByte(1)
      ..write(obj.fullName)
      ..writeByte(2)
      ..write(obj.username)
      ..writeByte(3)
      ..write(obj.phoneNumber)
      ..writeByte(4)
      ..write(obj.password)
      ..writeByte(5)
      ..write(obj.profilePictureUrl)
      ..writeByte(6)
      ..write(obj.bio)
      ..writeByte(7)
      ..write(obj.termsAccepted)
      ..writeByte(8)
      ..write(obj.userId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BuyerHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
