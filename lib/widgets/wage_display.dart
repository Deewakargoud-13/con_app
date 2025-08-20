import 'package:flutter/material.dart';
import '../models/attendance.dart';

class WageDisplay extends StatelessWidget {
  final AttendanceType attendanceType;
  final double wage;
  final double advance;

  const WageDisplay({Key? key, required this.attendanceType, required this.wage, required this.advance}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double multiplier;
    switch (attendanceType) {
      case AttendanceType.full:
        multiplier = 1.0;
        break;
      case AttendanceType.half:
        multiplier = 0.5;
        break;
      case AttendanceType.oneAndHalf:
        multiplier = 1.5;
        break;
      case AttendanceType.absent:
        multiplier = 0.0;
        break;
    }
    final calculated = wage * multiplier;
    final netWage = calculated - advance;
    return Text('₹${netWage.toStringAsFixed(2)}', style: TextStyle(color: netWage < 0 ? Colors.red : Colors.black));
  }
} 