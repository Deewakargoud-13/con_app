// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PaymentRecordAdapter extends TypeAdapter<PaymentRecord> {
  @override
  final int typeId = 3;

  @override
  PaymentRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PaymentRecord(
      date: fields[0] as DateTime,
      amountPaid: fields[1] as double,
      viaAdvance: fields[2] as bool,
      remaining: fields[3] as double,
    );
  }

  @override
  void write(BinaryWriter writer, PaymentRecord obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.amountPaid)
      ..writeByte(2)
      ..write(obj.viaAdvance)
      ..writeByte(3)
      ..write(obj.remaining);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
