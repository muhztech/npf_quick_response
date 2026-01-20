// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'evidence.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EvidenceAdapter extends TypeAdapter<Evidence> {
  @override
  final int typeId = 0;

  @override
  Evidence read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Evidence(
      encryptedPath: fields[0] as String,
      latitude: fields[1] as double,
      longitude: fields[2] as double,
      timestamp: fields[3] as DateTime,
      ivBase64: fields[5] as String,
      locationName: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Evidence obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.encryptedPath)
      ..writeByte(1)
      ..write(obj.latitude)
      ..writeByte(2)
      ..write(obj.longitude)
      ..writeByte(3)
      ..write(obj.timestamp)
      ..writeByte(4)
      ..write(obj.locationName)
      ..writeByte(5)
      ..write(obj.ivBase64);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EvidenceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
