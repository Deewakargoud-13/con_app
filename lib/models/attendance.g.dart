
part of 'attendance.dart';


class AttendanceRecordAdapter extends TypeAdapter<AttendanceRecord> {
  @override
  final int typeId = 2;

  @override
  AttendanceRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AttendanceRecord(
      date: fields[0] as DateTime,
      type: fields[1] as AttendanceType,
    );
  }

  @override
  void write(BinaryWriter writer, AttendanceRecord obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.type);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttendanceRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AttendanceTypeAdapter extends TypeAdapter<AttendanceType> {
  @override
  final int typeId = 1;

  @override
  AttendanceType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AttendanceType.full;
      case 1:
        return AttendanceType.half;
      case 2:
        return AttendanceType.oneAndHalf;
      case 3:
        return AttendanceType.absent;
      default:
        return AttendanceType.full;
    }
  }

  @override
  void write(BinaryWriter writer, AttendanceType obj) {
    switch (obj) {
      case AttendanceType.full:
        writer.writeByte(0);
        break;
      case AttendanceType.half:
        writer.writeByte(1);
        break;
      case AttendanceType.oneAndHalf:
        writer.writeByte(2);
        break;
      case AttendanceType.absent:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttendanceTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
