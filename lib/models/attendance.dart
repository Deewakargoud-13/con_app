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
} 