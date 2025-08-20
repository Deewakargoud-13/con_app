// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'worker.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkerAdapter extends TypeAdapter<Worker> {
  @override
  final int typeId = 4;

  @override
  Worker read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Worker(
      name: fields[0] as String,
      dailyWage: fields[1] as double,
      advance: fields[2] as double,
      attendance: (fields[3] as List?)?.cast<AttendanceRecord>(),
      payments: (fields[4] as List?)?.cast<PaymentRecord>(),
      advances: (fields[5] as List?)?.cast<AdvanceRecord>(),
    );
  }

  @override
  void write(BinaryWriter writer, Worker obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.dailyWage)
      ..writeByte(2)
      ..write(obj.advance)
      ..writeByte(3)
      ..write(obj.attendance)
      ..writeByte(4)
      ..write(obj.payments)
      ..writeByte(5)
      ..write(obj.advances);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AdvanceRecordAdapter extends TypeAdapter<AdvanceRecord> {
  @override
  final int typeId = 5;

  @override
  AdvanceRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return AdvanceRecord(
      date: fields[0] as DateTime,
      amount: fields[1] as double,
    );
  }

  @override
  void write(BinaryWriter writer, AdvanceRecord obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.amount);
  }
}
