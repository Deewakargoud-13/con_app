import 'package:flutter/material.dart';
import '../models/attendance.dart';

class AttendanceSelector extends StatelessWidget {
  final AttendanceRecord attendance;
  final ValueChanged<AttendanceType> onChanged;
  final bool editable;

  const AttendanceSelector({
    Key? key,
    required this.attendance,
    required this.onChanged,
    this.editable = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!editable) {
      return _buildChip(attendance.type, selected: true);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: AttendanceType.values.map((type) {
        if (attendance.type == type) {
          return _buildChip(type, selected: true);
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: ChoiceChip(
            label: Text(_typeLabel(type)),
            selected: false,
            backgroundColor: _typeColor(type).withOpacity(0.2),
            onSelected: (_) => onChanged(type),
            labelStyle: const TextStyle(fontSize: 12),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildChip(AttendanceType type, {bool selected = false}) {
    return Chip(
      label: Text(_typeLabel(type)),
      backgroundColor: _typeColor(type),
      labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
    );
  }

  String _typeLabel(AttendanceType type) {
    switch (type) {
      case AttendanceType.full:
        return 'Full';
      case AttendanceType.half:
        return 'Half';
      case AttendanceType.oneAndHalf:
        return '1½';
      case AttendanceType.absent:
        return 'Absent';
    }
  }

  Color _typeColor(AttendanceType type) {
    switch (type) {
      case AttendanceType.full:
        return Colors.green;
      case AttendanceType.half:
        return Colors.yellow.shade700;
      case AttendanceType.oneAndHalf:
        return Colors.blue;
      case AttendanceType.absent:
        return Colors.red;
    }
  }
} 