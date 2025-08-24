import 'package:hive/hive.dart';
part 'attendance.g.dart';

@HiveType(typeId: 1)
enum AttendanceType {
  @HiveField(0)
  full,
  @HiveField(1)
  half,
  @HiveField(2)
  oneAndHalf,
  @HiveField(3)
  absent,
}

@HiveType(typeId: 2)
class AttendanceRecord extends HiveObject {
  @HiveField(0)
  DateTime date;
  @HiveField(1)
  AttendanceType type;

  AttendanceRecord({required this.date, required this.type});

  factory AttendanceRecord.fromMap(Map<String, dynamic> map) {
    return AttendanceRecord(
      date: DateTime.parse(map['date']),
      type: AttendanceType.values.firstWhere((e) => e.name == map['type']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'type': type.name,
    };
  }
}
