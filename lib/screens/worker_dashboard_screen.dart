import 'package:flutter/material.dart';
import '../models/worker.dart';
import '../models/attendance.dart';
import '../models/payment.dart';
import '../widgets/attendance_selector.dart';
import '../widgets/wage_display.dart';
import '../widgets/advance_editor.dart';
import '../widgets/payment_buttons.dart';
import '../widgets/month_selector.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

double calculateFinalPending(List<AttendanceRecord> attendance, List<AdvanceRecord> advances, double dailyWage, DateTime month) {
  final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
  List<MapEntry<DateTime, double>> pendingQueue = [];
  double carryForward = 0.0;
  for (int i = 1; i <= daysInMonth; i++) {
    final date = DateTime(month.year, month.month, i);
    final att = attendance.firstWhere(
      (a) => a.date.year == date.year && a.date.month == date.month && a.date.day == date.day,
      orElse: () => AttendanceRecord(date: date, type: AttendanceType.absent),
    );
    final wage = dailyWage * (att.type == AttendanceType.full ? 1.0 : att.type == AttendanceType.half ? 0.5 : att.type == AttendanceType.oneAndHalf ? 1.5 : 0.0);
    if (wage > 0) {
      pendingQueue.add(MapEntry(date, wage));
    }
    final adv = advances.firstWhere(
      (a) => a.date.year == date.year && a.date.month == date.month && a.date.day == date.day,
      orElse: () => AdvanceRecord(date: date, amount: 0),
    );
    double availableAdvance = adv.amount + carryForward;
    int j = 0;
    while (availableAdvance > 0 && j < pendingQueue.length) {
      final entry = pendingQueue[j];
      final toClear = entry.value;
      if (availableAdvance >= toClear) {
        availableAdvance -= toClear;
        pendingQueue[j] = MapEntry(entry.key, 0.0);
      } else {
        pendingQueue[j] = MapEntry(entry.key, toClear - availableAdvance);
        availableAdvance = 0.0;
      }
      j++;
    }
    pendingQueue.removeWhere((entry) => entry.value == 0.0);
    carryForward = availableAdvance;
  }
  return pendingQueue.fold(0.0, (sum, entry) => sum + entry.value);
}

class WorkerDashboardScreen extends StatefulWidget {
  final Worker worker;
  const WorkerDashboardScreen({Key? key, required this.worker}) : super(key: key);

  @override
  State<WorkerDashboardScreen> createState() => _WorkerDashboardScreenState();
}

class _WorkerDashboardScreenState extends State<WorkerDashboardScreen> with WidgetsBindingObserver {
  late List<DateTime> monthDays;
  late DateTime selectedMonth;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    selectedMonth = DateTime.now();
    _updateMonthDays();
  }

  void _updateMonthDays() {
    final firstDay = DateTime(selectedMonth.year, selectedMonth.month, 1);
    final lastDay = DateTime(selectedMonth.year, selectedMonth.month + 1, 0);
    monthDays = List.generate(
      lastDay.day,
      (i) => DateTime(selectedMonth.year, selectedMonth.month, i + 1),
    );
    // Ensure attendance records exist for each day
    bool hasNewRecords = false;
    for (final day in monthDays) {
      if (!widget.worker.attendance.any((a) => isSameDay(a.date, day))) {
        widget.worker.attendance.add(AttendanceRecord(date: day, type: AttendanceType.absent));
        hasNewRecords = true;
      }
    }
    // Save to Hive if new records were added
    if (hasNewRecords) {
      Provider.of<WorkerListModel>(context, listen: false).saveToHive();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      // Save data when app is paused or detached
      Provider.of<WorkerListModel>(context, listen: false).saveToHive();
    }
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    final headerFontSize = isTablet ? 20.0 : 14.0;
    final cellFontSize = isTablet ? 18.0 : 12.0;
    final padding = isTablet ? 24.0 : 8.0;
    final isCurrentMonth = selectedMonth.year == today.year && selectedMonth.month == today.month;

    // --- Calculate selected month total pending using new advance-clears-oldest-pending logic ---
    double monthPending = calculateFinalPending(
      widget.worker.attendance,
      widget.worker.advances,
      widget.worker.dailyWage,
      selectedMonth,
    );

    // --- Calculate total advances for the selected month ---
    double selectedMonthAdvance = widget.worker.advances
        .where((a) => a.date.year == selectedMonth.year && a.date.month == selectedMonth.month)
        .fold(0.0, (sum, a) => sum + a.amount);

    // --- Calculate sum of all negative advances for the selected month ---
    double totalNegativeAdvance = widget.worker.advances
      .where((a) => a.date.year == selectedMonth.year && a.date.month == selectedMonth.month && a.amount < 0)
      .fold(0.0, (sum, a) => sum + a.amount);

    // --- Precompute daily results for the whole month with pending queue logic ---
    Map<DateTime, double> advanceAfterDeduction = {};
    Map<DateTime, double> pendingForDayMap = {};
    List<MapEntry<DateTime, double>> pendingQueue = [];
    double carryForward = 0.0;
    for (final day in monthDays) {
      final advanceRecord = widget.worker.advances.firstWhere(
        (a) => isSameDay(a.date, day),
        orElse: () => AdvanceRecord(date: day, amount: 0),
      );
      final attendance = widget.worker.attendance.firstWhere((a) => isSameDay(a.date, day));
      final wage = widget.worker.dailyWage * _attendanceMultiplier(attendance.type);
      double availableAdvance = advanceRecord.amount + carryForward;
      // 1. Add today's pending to the queue
      if (wage > 0) {
        pendingQueue.add(MapEntry(day, wage));
      }
      // 2. Use available advance to clear oldest pending first
      int i = 0;
      while (availableAdvance > 0 && i < pendingQueue.length) {
        final entry = pendingQueue[i];
        final toClear = entry.value;
        if (availableAdvance >= toClear) {
          // Fully clear this day's pending
          availableAdvance -= toClear;
          pendingQueue[i] = MapEntry(entry.key, 0.0);
        } else {
          // Partially clear this day's pending
          pendingQueue[i] = MapEntry(entry.key, toClear - availableAdvance);
          availableAdvance = 0.0;
        }
        i++;
      }
      // 3. Store the pending for each day
      for (final entry in pendingQueue) {
        pendingForDayMap[entry.key] = entry.value;
      }
      // 4. Remove fully paid days from the queue
      pendingQueue.removeWhere((entry) => entry.value == 0.0);
      // 5. Carry forward any leftover advance
      carryForward = availableAdvance;
    }

    return Scaffold(
      appBar: AppBar(title: Text('${widget.worker.name} (₹${widget.worker.dailyWage.toStringAsFixed(2)})')),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          children: [
            // --- Month Selector ---
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MonthSelector(
                    selectedDate: selectedMonth,
                    onMonthChanged: (newMonth) {
                      setState(() {
                        selectedMonth = newMonth;
                        _updateMonthDays();
                      });
                    },
                  ),
                  if (totalNegativeAdvance < 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text('Total Negative Advance: ₹${totalNegativeAdvance.abs().toStringAsFixed(2)}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: screenWidth),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      columnSpacing: isTablet ? 32 : 12,
                      headingRowHeight: isTablet ? 60 : 40,
                      dataRowHeight: isTablet ? 80 : 60,
                      columns: [
                        DataColumn(label: Text('Date', style: TextStyle(fontSize: headerFontSize, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Attendance', style: TextStyle(fontSize: headerFontSize, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Wage', style: TextStyle(fontSize: headerFontSize, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Advance', style: TextStyle(fontSize: headerFontSize, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Remaining Advance', style: TextStyle(fontSize: headerFontSize, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Payment', style: TextStyle(fontSize: headerFontSize, fontWeight: FontWeight.bold))),
                      ],
                      rows: [
                        ...monthDays.map((date) {
                          final isFuture = date.isAfter(DateTime(today.year, today.month, today.day));
                          final attendance = widget.worker.attendance.firstWhere((a) => isSameDay(a.date, date));
                          final wageForDay = widget.worker.dailyWage * _attendanceMultiplier(attendance.type);
                          final advanceRecord = widget.worker.advances.firstWhere(
                            (a) => isSameDay(a.date, date),
                            orElse: () => AdvanceRecord(date: date, amount: 0),
                          );
                          // Calculate available advance for this day (advance + carry-forward)
                          double carryForward = 0.0;
                          if (date.day > 1) {
                            final prevDate = DateTime(date.year, date.month, date.day - 1);
                            carryForward = advanceAfterDeduction[prevDate] ?? 0.0;
                          }
                          final availableAdvance = advanceRecord.amount + carryForward;
                          double usedAdvance = availableAdvance >= wageForDay ? wageForDay : availableAdvance;
                          double remainingAdvance = availableAdvance - usedAdvance;
                          double pending = pendingForDayMap[date] ?? 0.0;
                          // Store carry-forward for next day
                          advanceAfterDeduction[date] = remainingAdvance > 0 ? remainingAdvance : 0.0;
                          return DataRow(cells: [
                            DataCell(Text(DateFormat('dd MMM (E)').format(date), style: TextStyle(fontSize: cellFontSize))),
                            DataCell(!isCurrentMonth || !date.isAfter(today)
                                ? AttendanceSelector(
                                    attendance: attendance,
                                    onChanged: (type) {
                                      setState(() {
                                        attendance.type = type;
                                      });
                                      Provider.of<WorkerListModel>(context, listen: false).saveToHive();
                                    },
                                    editable: !isCurrentMonth || !date.isAfter(today),
                                  )
                                : Text('-', style: TextStyle(fontSize: cellFontSize))),
                            DataCell(Text('₹${wageForDay.toStringAsFixed(2)}', style: TextStyle(fontSize: cellFontSize))),
                            DataCell(!isCurrentMonth || !date.isAfter(today)
                                ? AdvanceEditor(
                                    worker: widget.worker,
                                    date: date,
                                    editable: !isCurrentMonth || !date.isAfter(today),
                                    onAdvanceChanged: (newAdvance) {
                                      setState(() {
                                        final idx = widget.worker.advances.indexWhere((a) => isSameDay(a.date, date));
                                        if (idx >= 0) {
                                          widget.worker.advances[idx].amount = newAdvance;
                                        } else {
                                          widget.worker.advances.add(AdvanceRecord(date: date, amount: newAdvance));
                                        }
                                      });
                                      Provider.of<WorkerListModel>(context, listen: false).saveToHive();
                                    },
                                  )
                                : Text('-', style: TextStyle(fontSize: cellFontSize))),
                            DataCell(Text(remainingAdvance > 0 ? remainingAdvance.toStringAsFixed(2) : '0.00', style: TextStyle(fontSize: cellFontSize))),
                            DataCell(attendance.type == AttendanceType.absent
                                ? const Text('')
                                : (pending <= 0
                                    ? const Text('Paid', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
                                    : Text('Pending ₹${pending.toStringAsFixed(2)}', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)))),
                          ]);
                        }),
                        // --- Add summary row for selected month pending ---
                        DataRow(
                          color: MaterialStateProperty.all(Colors.transparent),
                          cells: [
                            DataCell(Container()), // Date
                            DataCell(Container()), // Attendance
                            DataCell(Container()), // Wage
                            DataCell(Container()), // Advance
                            DataCell(Container()), // Remaining Advance
                            DataCell(
                              Center(
                                child: (selectedMonthAdvance > widget.worker.dailyWage * monthDays.length)
                                    ? Padding(
                                        padding: const EdgeInsets.only(top: 4.0),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade100,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text('Advance Balance: ₹${(selectedMonthAdvance - widget.worker.dailyWage * monthDays.length).toStringAsFixed(2)}', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                                        ),
                                      )
                                    : (monthPending == 0)
                                        ? Padding(
                                            padding: const EdgeInsets.only(top: 4.0),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: Colors.green.shade100,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: const Text('Clear', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                            ),
                                          )
                                        : Padding(
                                            padding: const EdgeInsets.only(top: 4.0),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: Colors.orange.shade100,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text('Pending ₹${monthPending.toStringAsFixed(2)}', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                                            ),
                                          ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // --- Add summary for advances ---
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Advance (${DateFormat('MMM yyyy').format(selectedMonth)}): ₹${selectedMonthAdvance.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 24),
                ],
              ),
            ),
          ],
        ),
      ),
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