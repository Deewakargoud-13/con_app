import 'package:flutter/material.dart';
import '../models/worker.dart';
import '../models/attendance.dart';
import '../models/payment.dart';

class PaymentButtons extends StatelessWidget {
  final Worker worker;
  final DateTime date;
  final AttendanceType attendanceType;
  final PaymentRecord payment;
  final void Function(double amount, bool viaAdvance) onPayment;

  const PaymentButtons({
    Key? key,
    required this.worker,
    required this.date,
    required this.attendanceType,
    required this.payment,
    required this.onPayment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final wage = worker.dailyWage * _attendanceMultiplier(attendanceType);
    final remaining = wage - payment.amountPaid;
    if (wage == 0) {
      return const Text('N/A');
    }
    if (payment.amountPaid >= wage) {
      return const Chip(label: Text('Paid'), backgroundColor: Colors.green, labelStyle: TextStyle(color: Colors.white));
    }
    // Show status if partial payment
    final statusWidget = payment.amountPaid > 0 && payment.amountPaid < wage
        ? Chip(
            label: Text('Pending ₹${remaining.toStringAsFixed(2)}'),
            backgroundColor: Colors.orange,
            labelStyle: const TextStyle(color: Colors.white),
          )
        : null;
    // Find advance for this date
    final advanceRecord = worker.advances.firstWhere(
      (a) => a.date.year == date.year && a.date.month == date.month && a.date.day == date.day,
      orElse: () => AdvanceRecord(date: date, amount: 0),
    );
    final availableAdvance = advanceRecord.amount;
    final netWage = wage - availableAdvance;
    if (wage == 0) {
      return const Text('N/A');
    }
    if (netWage <= 0) {
      return const Chip(label: Text('Paid'), backgroundColor: Colors.green, labelStyle: TextStyle(color: Colors.white));
    }
    // Show status if partial or negative payment
    return Chip(
      label: Text(netWage > 0 ? 'Pending ₹${netWage.toStringAsFixed(2)}' : 'Negative ₹${netWage.abs().toStringAsFixed(2)}'),
      backgroundColor: netWage > 0 ? Colors.orange : Colors.red,
      labelStyle: const TextStyle(color: Colors.white),
    );
  }

  double _attendanceMultiplier(AttendanceType type) {
    switch (type) {
      case AttendanceType.full:
        return 1.0;
      case AttendanceType.half:
        return 0.5;
      case AttendanceType.oneAndHalf:
        return 1.5;
      case AttendanceType.absent:
        return 0.0;
    }
  }
} 