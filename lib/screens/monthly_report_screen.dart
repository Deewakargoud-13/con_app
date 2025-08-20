import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/worker.dart';
import '../models/attendance.dart';

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

class MonthlyReportScreen extends StatelessWidget {
  const MonthlyReportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final workerList = Provider.of<WorkerListModel>(context);
    final today = DateTime.now();
    final currentMonth = today.month;
    final currentYear = today.year;

    double totalAllPending = 0;

    List<Map<String, dynamic>> reportRows = workerList.workers.map((worker) {
      double totalWage = 0;
      double totalAdvance = 0;
      int presentDays = 0;
      List<MapEntry<DateTime, double>> pendingQueue = [];
      double carryForward = 0.0;
      final today = DateTime.now();
      final currentMonth = today.month;
      final currentYear = today.year;
      final daysInMonth = DateUtils.getDaysInMonth(currentYear, currentMonth);
      for (int i = 1; i <= daysInMonth; i++) {
        final date = DateTime(currentYear, currentMonth, i);
        final attendance = worker.attendance.firstWhere(
          (a) => a.date.year == date.year && a.date.month == date.month && a.date.day == date.day,
          orElse: () => AttendanceRecord(date: date, type: AttendanceType.absent),
        );
        if (attendance.type != AttendanceType.absent) presentDays++;
        final wageForDay = worker.dailyWage * (attendance.type == AttendanceType.full ? 1.0 : attendance.type == AttendanceType.half ? 0.5 : attendance.type == AttendanceType.oneAndHalf ? 1.5 : 0.0);
        final advanceRecord = worker.advances.firstWhere(
          (a) => a.date.year == date.year && a.date.month == date.month && a.date.day == date.day,
          orElse: () => AdvanceRecord(date: date, amount: 0),
        );
        double availableAdvance = advanceRecord.amount + carryForward;
        // 1. Add today's pending to the queue
        if (wageForDay > 0) {
          pendingQueue.add(MapEntry(date, wageForDay));
        }
        // 2. Use available advance to clear oldest pending first
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
        // 3. Remove fully paid days from the queue
        pendingQueue.removeWhere((entry) => entry.value == 0.0);
        // 4. Carry forward any leftover advance
        carryForward = availableAdvance;
        totalWage += wageForDay;
        totalAdvance += advanceRecord.amount;
        // 4. Carry forward any leftover advance
        carryForward = availableAdvance;
      }
      double totalPending = calculateFinalPending(worker.attendance, worker.advances, worker.dailyWage, DateTime(currentYear, currentMonth));
      return {
        'name': worker.name,
        'presentDays': presentDays,
        'totalWage': totalWage,
        'totalAdvance': totalAdvance,
        'pending': totalPending,
        'remainingAdvance': 0.0, // Not used in summary
      };
    }).toList();

    // Correctly sum all workers' pending values for the month
    totalAllPending = reportRows.fold(0.0, (sum, row) => sum + (row['pending'] as double));

    return Scaffold(
      appBar: AppBar(title: const Text('Monthly Report')),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: reportRows.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final row = reportRows[index];
                  return Card(
                    color: Colors.blue.shade50,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      title: Text(row['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total Wage: ₹${row['totalWage'].toStringAsFixed(2)}'),
                          Text('Total Advance: ₹${row['totalAdvance'].toStringAsFixed(2)}'),
                          Text('Days Present: ${row['presentDays']}'),
                          Text('Remaining Advance: ₹${row['remainingAdvance'].toStringAsFixed(2)}'),
                          (row['totalAdvance'] > row['totalWage'])
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text('Advance Balance: ₹${(row['totalAdvance'] - row['totalWage']).toStringAsFixed(2)}', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                                  ),
                                )
                              : row['pending'] == 0
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
                                        child: Text('Pending ₹${row['pending'].toStringAsFixed(2)}', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            totalAllPending == 0
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Text('Clear', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 20)),
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text('Total Pending: ₹${totalAllPending.toStringAsFixed(2)}', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 20)),
                  ),
          ],
        ),
      ),
    );
  }
} 