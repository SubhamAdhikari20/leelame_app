// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_condition_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductConditionHiveModelAdapter
    extends TypeAdapter<ProductConditionHiveModel> {
  @override
  final typeId = 6;

  @override
  ProductConditionHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProductConditionHiveModel(
      productConditionId: fields[0] as String?,
      productConditionName: fields[1] as String,
      description: fields[2] as String?,
      productConditionEnum: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ProductConditionHiveModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.productConditionId)
      ..writeByte(1)
      ..write(obj.productConditionName)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.productConditionEnum);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductConditionHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
