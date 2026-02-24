// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductHiveModelAdapter extends TypeAdapter<ProductHiveModel> {
  @override
  final typeId = 4;

  @override
  ProductHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProductHiveModel(
      productId: fields[0] as String?,
      sellerId: fields[1] as String?,
      productName: fields[2] as String,
      description: fields[3] as String?,
      categoryId: fields[4] as String?,
      conditionId: fields[5] as String?,
      commission: (fields[6] as num).toDouble(),
      startPrice: (fields[7] as num).toDouble(),
      currentBidPrice: (fields[8] as num).toDouble(),
      bidIntervalPrice: (fields[9] as num).toDouble(),
      endDate: fields[10] as DateTime,
      productImageUrls: (fields[11] as List).cast<String>(),
      isVerified: fields[12] as bool,
      isSoldOut: fields[13] as bool,
      soldToBuyerId: fields[14] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ProductHiveModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.productId)
      ..writeByte(1)
      ..write(obj.sellerId)
      ..writeByte(2)
      ..write(obj.productName)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.categoryId)
      ..writeByte(5)
      ..write(obj.conditionId)
      ..writeByte(6)
      ..write(obj.commission)
      ..writeByte(7)
      ..write(obj.startPrice)
      ..writeByte(8)
      ..write(obj.currentBidPrice)
      ..writeByte(9)
      ..write(obj.bidIntervalPrice)
      ..writeByte(10)
      ..write(obj.endDate)
      ..writeByte(11)
      ..write(obj.productImageUrls)
      ..writeByte(12)
      ..write(obj.isVerified)
      ..writeByte(13)
      ..write(obj.isSoldOut)
      ..writeByte(14)
      ..write(obj.soldToBuyerId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
