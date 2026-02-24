// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bid_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BidHiveModelAdapter extends TypeAdapter<BidHiveModel> {
  @override
  final typeId = 7;

  @override
  BidHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BidHiveModel(
      bidId: fields[0] as String?,
      productId: fields[1] as String?,
      buyerId: fields[2] as String?,
      bidAmount: (fields[3] as num).toDouble(),
    );
  }

  @override
  void write(BinaryWriter writer, BidHiveModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.bidId)
      ..writeByte(1)
      ..write(obj.productId)
      ..writeByte(2)
      ..write(obj.buyerId)
      ..writeByte(3)
      ..write(obj.bidAmount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BidHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
